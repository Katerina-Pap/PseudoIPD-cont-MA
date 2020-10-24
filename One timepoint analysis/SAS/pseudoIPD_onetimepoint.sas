*------------------------------------------------------------------------------
* 	  example dataset: iron levels for alzheimer and control group   								
*------------------------------------------------------------------------------;
data iron; input study year meancontrol sdcontrol ncontrol meanAD sdAD nAD;
datalines;
1 1991         114        25       26    100   39  20
2 1993          89        32       20     90   33  26
3 1996          63        30      421     56   22  31
4 1998         101        31       28    114   35  26
5 2010          81        31       50     67   23  50
;

proc print noobs; var study meancontrol sdcontrol ncontrol meanAD sdAD nAD; run;  

data iron; set iron;
varcontrol = sdcontrol*sdcontrol;
varAD      = sdAD*sdAD;
dif        = meanAD - meancontrol ;
* pooled variance per study;
 varpooled = ((ncontrol-1)*varcontrol + (nAD-1)*varAD)/(ncontrol+nAD-2);
 vdif = varpooled*(1/ncontrol+1/nAD);
 row =_n_; col=_n_;value=vdif;
run;
proc print data=iron; run;

* run random effects AD meta-analysis;
proc mixed data = iron order=data;
class study;
model dif= /  solution cl;
random study/gdata=iron s;
repeated diag;
run;

*------------------------------------------------------------------------------
*             Make  pseudo IPD
* Generate ytmp from standard normal distribution 
*------------------------------------------------------------------------------;
data ipd;set iron;
do patient=1 to ncontrol;              group=0; meangr=meancontrol; sdgr=sdcontrol;ytmp=rannor(735625);output;end;
do patient=ncontrol+1 to ncontrol+nAD; group=1;  meangr=meanAD; sdgr=sdAD; ytmp=rannor(876545);output;end;
run;

* make sure that mean(ytmp)= 0 and sd(ytmp)= 1 per group within study;
proc standard data=ipd mean=0 std=1 replace
              print out=zscore;
              by study group;
* check;
proc means data=zscore;by study group;var ytmp;            

* merge the standardized Ys to the original ipd data;
data ipd;
   merge ipd (drop=ytmp)
         zscore (keep=ytmp);
  y = ytmp*sdgr +meangr;
  
* check;
proc means data=ipd;by study group;var ytmp y meangr sdgr;       

data ipd; set ipd;      
arm=100*study+group;
keep study group arm  y meangr sdgr;
*proc print;run;

data ipd;set ipd;groupc=group;

* Define the components for the starting values;
proc print data = iron;run;

* Calculate starting values for proc mixed;
* the tau matrix with study and treatment effect;
proc corr data=iron  cov outp=tau_full;
var meancontrol dif;
run;
proc print data = tau_full; run;
* Get only the variances and correlation of the tau matrix;
data tau_full; set tau_full;
IF (_TYPE_ = 'COV' AND  _NAME_ = 'meancontrol') THEN EST =meancontrol;
IF (_TYPE_ = 'COV' AND  _NAME_ = 'dif') THEN EST =dif;
IF (_TYPE_ = 'CORR' AND  _NAME_ = 'meancontrol') THEN EST =dif;
IF (EST = .) THEN DELETE;
KEEP EST
run;

proc print;run;

* And starting values for the variance matrix
* 1. Observed variances per study and arm;
proc transpose data=iron (rename=(varcontrol  =EST1) rename=(varAD=EST2) keep = varcontrol varAD study) out=s_full;
   by study ;
run;
proc print data =s_full;run;
data s_full; set s_full (rename=(col1  =EST));
keep EST;
proc print data=s_full;run;

* 2. Observed pooled variances per study;
data s_study; set iron( rename=(varpooled=EST));
keep EST;
proc print data=s_study;
run;
* 3. Observed pooled variances per treatment arm;
data iron; set iron;
sscontrol=varcontrol*(ncontrol-1);
ssAD=varAD*(nAD-1);

proc means data=iron sum;
    var ncontrol sscontrol nAD ssAD;
   ods output Summary=temp1;  /* write statistics to data set */
run;
data temp1; set temp1;
 EST1 = sscontrol_sum/(ncontrol_sum-1);
 EST2 = ssAD_sum/(nAD_sum-1);
 keep EST1 EST2;
run;
data s_treatment; set temp1 (rename=(EST1=EST)) temp1 (rename=(EST2=EST));
keep EST;
proc print data=s_treatment;run;
run;

* Observed pooled variance for two groups within a study;
data iron; set iron;
proc means data=iron sum;
var ncontrol sscontrol;
ods output Summary=temp2;  /* write statistics to data set */
run;
data temp2; set temp2;
 EST1 = sscontrol_sum/(ncontrol_sum-1);
  keep EST1;
run;
data s_overall; set temp2 (rename=(EST1=EST));
keep EST;
proc print data=s_overall;run;
run;

*------------------------------------------------------------------------------
*  Fit one-stage pseudo IPD models 
*------------------------------------------------------------------------------;

*------------------------------------------
* study and treatment both fixed 
*------------------------------------------;

* arm/trial specific variances estimated;
data startvalues; set s_full;
proc print data=startvalues; run;
proc mixed data=ipd method = reml covtest;
class study arm;
model y= study group/s cl ddfm=con;
parms/parmsdata = startvalues; 
repeated/group=arm;
run;

** trial specific variances estimated;
data startvalues; set s_study;
proc mixed data=ipd method = reml;
class study arm;
model y= study group/s cl ddfm=con;
parms/parmsdata = startvalues; 
repeated/group=study;
run;

** group specific variances estimated;
data startvalues; set s_treatment;
proc mixed data=ipd method = reml;
class study groupc;
model y= study group/s cl ddfm=con;
parms/parmsdata = startvalues; 
repeated/group=groupc;
run;

** one residual variance;
data startvalues; set s_overall;
proc mixed data=ipd method = reml;
class study groupc;
model y= study group/s cl ddfm=con;
parms/parmsdata = startvalues; 
run;

*------------------------------------------
* study fixed and treatmen random 
*------------------------------------------;
* Calculate observed tau (=variance of treatment differences between studies) to obtain starting values;

proc means  data=iron var;
var dif;
output out=tau_small  var=EST;
run;
proc print; run;

data startvalues;set tau_small s_full;
keep EST;
run;
proc print;run;

** arm/trial specific variances estimated;
proc mixed data=ipd method = reml;
class study arm;
model y= study group/s cl ddfm=con;
random group /subject=study type=unr s;
*parms (0.5) (623) (5859) (1016) (4279) (899) (1896) (965) (5052) (961) (2118)  ;
parms/parmsdata = startvalues;
repeated/group=arm;
run;

** trial specific variances estimated;
data startvalues; set tau_small s_study;
proc mixed data=ipd method = reml;
class study arm;
model y= study group/s cl ddfm=con;
random group /subject=study type=unr s;
parms/parmsdata = startvalues;
*parms (21)(862.18)(1049.16)(885.66) (1042.23) (818.97) /eqcons=2 to 6;
repeated/group=study;
run;

** group specific variances estimated;
data startvalues; set tau_small  s_treatment;
proc mixed data=ipd method = reml;
class study groupc;
model y= study group/s cl ddfm=con;
random group /subject=study type=unr s;
parms/parmsdata = startvalues;
repeated/group=groupc;
run;


** one residual variance;
data startvalues; set tau_small s_overall;
proc mixed data=ipd method = reml;
class study groupc;
model y= study group/s cl ddfm=con;
random group /subject=study type=unr s;
parms/parmsdata = startvalues;
ods output CovParms=CovParms;
run;


** residual variances fixed to observed;

data parameters;set tau_small s_full(rename =(col1=EST));
keep EST;
run;
proc print data = parameters;run;

proc mixed data=ipd method = reml;
class study arm;
model y= study group/s cl ddfm=con;
random  group /subject=study type=unr s;
parms/parmsdata = parameters eqcons=2 to 11;
repeated/group=arm;
run;


*------------------------------------------
* study and treatment both random 
*------------------------------------------;

** arm/trial specific variances estimated;

data startvalues; set tau_full s_full;
proc print data =startvalues; run; 

proc mixed data=ipd method = reml covtest;
class study arm;
model y= group/solution cl ddfm=con;
random int group /subject=study type=unr s;
parms/parmsdata = startvalues;
repeated/group=arm;
parms/parmsdata = startvalues;
run;

** trial specific variances estimated;
data startvalues; set tau_full s_study;
proc mixed data=ipd method = reml covtest;
class study arm;
model y= group/solution cl ddfm=con;
random int group /subject=study type=unr s;
parms/parmsdata = startvalues;
repeated/group=study;
run;

** group specific variances estimated;
data startvalues; set tau_full s_treatment;
proc mixed data=ipd method = reml;
class study groupc;
model y= group/s cl ddfm=con;
random int group /subject=study type=unr s;
*parms (320.64)(11.031)(0.8632)(850) (850);
parms/parmsdata = startvalues;
ods output CovParms=CovParms ;
repeated/group=groupc;
run;

***one residual variance;
data startvalues; set tau_full s_overall;
proc mixed data=ipd method = reml;
class study groupc;
model y= group/s cl ddfm=SATTERTHWAITE;
random int group /subject=study type=unr s;
parms/parmsdata = startvalues;
ods output CovParms=CovParms ;
run;

** residual variances fixed to observed variances;
data startvalues; set tau_full s_full;
proc mixed data=ipd method = reml;
class study arm;
model y= group/s cl ddfm=con;
random int group /subject=study type=unr;
parms/parmsdata = startvalues eqcons=4 to 13;
repeated/group=arm;
run;



