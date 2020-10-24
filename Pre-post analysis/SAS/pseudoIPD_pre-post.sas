*------------------------------------------------------------------------------
* Import data: Wang (baseline balanced case), imbalanced Wang and sleep apnea
*------------------------------------------------------------------------------;

data Wang;
	input study Studyname$ MeanBaseline sdBaseline  
		MeanPost sdPost  Correlation group;
	datalines;
1 ATMH    152.28 15.25 132.85 16.72 0.265 780 1
2 HEP     189.94 16.15 165.06 20.03 0.335 150 1
3 EWPHE   177.33 15.85 156.88 21.26 0.462 90 1
4 HDFP    151.68 19.83 130.09 19.25 0.337 2427 1
5 MRC-1   156.6  16.09 135.49 16.32 0.346 3546 1
6 MRC-2   182.19 12.63 153.99 20.13 0.178 1314 1
7 SHEP    170.49 9.5   145.1  19.05 0.315 2365 1
8 STOP    194.68 12.21 171.46 19.29 0.177 137 1
9 Sy-Chi  170.73 10.9  150.2  15.84 0.199 1252 1
10 Sy-Eur 173.75 9.86  154.87 16.31 0.319 2398 1
1 ATMH    153.05 15.73 139.75 17.85 0.284 750 0
2 HEP     191.55 17.64 179.89 22.15 0.331 199 0
3 EWPHE   178.23 15.06 170.45 26.91 0.534 82 0
4 HDFP    151    19.53 138.54 21.26 0.408 2370 0
5 MRC-1   156.65 15.96 144.25 17.58 0.416 3445 0
6 MRC-2   182.13 12.73 164.58 19.71 0.137 1337 0
7 SHEP    170.12 9.24  156.24 20.12 0.253 2371 0
8 STOP    194.15 11.16 189.11 21.9  0.414 131 0
9 Sy-Chi  170.25 11.41 156.55 16.86 0.347 1139 0
10 Sy-Eur 173.94 10.07 165.24 16.33 0.431 2297 0
;

data Wang_imbalance;
	input study Studyname$ MeanBaseline sdBaseline  
		MeanPost sdPost  Correlation 
		MeanCFB sdCFB Nobs group;
	datalines;
1 ATMH    147.28 15.25 127.85 16.72 0.265 -19.43 19.42 780 1
2 HEP     184.94 16.15 160.06 20.03 0.335 -24.88 21.11 150 1
3 EWPHE   177.33 15.85 156.88 21.26 0.462 -20.46 19.79 90 1
4 HDFP    131.68 19.83 110.09 19.25 0.337 -21.59 22.51 2427 1
5 MRC-1   136.6  16.09 115.49 16.32 0.346 -21.01 18.53 3546 1
6 MRC-2   172.19 12.63 143.99 20.13 0.178 -28.2 21.78 1314 1
7 SHEP    170.49 9.5   145.1  19.05 0.315 -25.39 18.42 2365 1
8 STOP    194.68 12.21 171.46 19.29 0.177 -23.22 20.93 137 1
9 Sy-Chi  170.73 10.9  150.2  15.84 0.199 -20.53 17.35 1252 1
10 Sy-Eur 173.75 9.86  154.87 16.31 0.319 -18.89 16.15 2398 1
1 ATMH    153.05 15.73 139.75 17.85 0.284 -13.3 20.16 750 0
2 HEP     191.55 17.64 179.89 22.15 0.331 -11.65 23.3 199 0
3 EWPHE   178.23 15.06 170.45 26.91 0.534 -7.78 22.76 82 0
4 HDFP    151    19.53 138.54 21.26 0.408 -12.46 22.24 2370 0
5 MRC-1   156.65 15.96 144.25 17.58 0.416 -12.39 18.18 3445 0
6 MRC-2   182.13 12.73 164.58 19.71 0.137 -17.55 21.95 1337 0
7 SHEP    170.12 9.24  156.24 20.12 0.253 -13.88 19.9 2371 0
8 STOP    194.15 11.16 189.11 21.9  0.414 -5.04 20.05 131 0
9 Sy-Chi  170.25 11.41 156.55 16.86 0.347 -13.7 16.77 1139 0
10 Sy-Eur 173.94 10.07 165.24 16.33 0.431 -8.7  15.04 2297 0
;

data apnea;
	input study Studyname$ MeanBaseline sdBaseline  
		MeanPost sdPost Nobs Correlation group;
	datalines;
1 Egea     43.7 22.9 10.8 11.4 27 0.4979 1
2 Haensel  65.9 28.6 3.5 3.4 25 0.4981 1
3 Loredo99 56.4 24.1 3.3 3.8 23 0.4442 1
4 Mills 65 34 2.56 2.4 17 0.4969 1
5 Loredo06 65.9 28.6 3 4.7 22 0.5704 1
6 Norman   66.1 29.1 3.4 3.0 18 0.4967 1
7 Becker   62.5 17.8 3.4 3.1 16 0.5025 1
8 Spicuzza 55.3 11.9 2.1 0.3 15 0.5052 1
1 Egea     35.3 16.7 28 24.8 29 0.4979 0
2 Haensel  57.5 32.1 53.4 32.9 25 0.4981 0
3 Loredo99 44.2 25.3 28.3 22.7 18 0.4442 0
4 Mills    61.2 41 57.3 41 16 0.4969 0
5 Loredo06 57.5 32.1 52.5 37.5 19 0.5704 0
6 Norman   53.9 29.8 50.1 32.1 15 0.4967 0
7 Becker   65.0 26.7 33.4 29.2 16  0.5025 0
8 Spicuzza 59.2 17.3 57 8.6 10 0.5052 0
;

proc print; run;
proc means;
run;

*------------------------------------------------------------------------------
*                     Generate pseudo IPD              
*------------------------------------------------------------------------------;

* Simulate two samples Yi1 and Yi2 of size nobs from N(0,1);
data temp;	set Wang; **change this for analysis of the other datasets
	do ID=1 to Nobs;
		ytmp1=rannor(123456);
		ytmp2=rannor(7891011);
		output;
	end;
run;

proc sort data=temp;
          by study group; run;

* Standardize ytmp1 and ytmp2;
proc standard data=temp mean=0 std=1 out=temp2;
  var ytmp1 ytmp2;
  by study group;
run;

* Regress ytmp2 on ytmp1, save residuals (ytmp22) and the regression coefficient (which is equal to cor(y1tmp, y2tmp));
ods output ParameterEstimates = parms;
 proc reg data=temp2 plots=none;
      model ytmp2=ytmp1/noint;
      output out=temp3  r=ytmp22;
	  by study group;
run;
   
* Check that correlation of ytmp1 and ytmp2 by group and study is equal to beta from regresion;   
proc corr data=temp2 ;
var ytmp1 ytmp2;
by study group;
run;
 

* Generate the IPD;
data ipd;
	merge temp3 parms(keep = study group estimate);* Add the correlation between ytmp1 and ytmp2(estimate) to the ipd dataset;
	by study group;
	* generate ytmp3 with sd(ytmp3) = 1, cor(ytmp3, ytmp1) = observed correlation; 
	ytmp3 = correlation*ytmp1+ sqrt(1-Correlation*Correlation)*ytmp22/sqrt(1-estimate*estimate); 
	y1 = ytmp1*sdBaseline+MeanBaseline ; * y1 now has mean and sd of original data;
    y2 = ytmp3*sdPost +meanPost; * y2 has mean and sd of original data ;
	drop ytmp1 ytmp2 ytmp22 ytmp3 estimate;
run;

* a check to see if mean pseudo baselines and mean pseudo outcomes are equal to reported mean baseline per group and mean post baseline outcomes;
proc means data=ipd;
	class study group;
	var y1 y2 Meanbaseline Meanpost sdbaseline sdpost Correlation;
run;

proc corr ;
var y1 y2;
by study group; run;

*--------------------------------------------------------
*  Some data Preparations before the LMM  
*--------------------------------------------------------;
data ipd; set ipd;
	arm=100*study+group;
	keep study group arm y1 y2;
run;

* data are centered to prevent convergence problems;
proc means DATA=ipd NWAY NOPRINT;
	CLASS study;
	VAR y1;
	OUTPUT OUT=means_y1(drop=_TYPE_ _FREQ_) mean=;
RUN;

data ipd;
	merge ipd means_y1(rename=(y1=mean_y1));
	by study;
run;

data ipd; set ipd;
y1center = y1 - mean_y1;
meanstudy = mean_y1;
groupc=group;
groupcenter = group-0.5;
run;

*------------------------------------------------------------------------------
*  One stage ANCOVA using the pseudo IPD and LMM 
*------------------------------------------------------------------------------;
*--------------------------------------------------------
*  Stratified study models            
*--------------------------------------------------------;

title "Arm/study specific variances";
proc mixed data=ipd method = reml;
class study arm;
model y2= y1center study y1center*study groupcenter/s CL ddfm=betwithin;
random group/subject=study type=un s;
repeated/group=arm;
run;

title "Arm/study specific variances, with interaction of baseline with treatment separating within and across-trial interaction"; 
** arm/study specific variances estimated;* interaction of baseline with treament added; 
proc mixed data=ipd method = reml;
class study arm;
model y2= y1center study group y1center*study group*y1center group*meanstudy/s cl ddfm=betwithin;
random groupcenter groupcenter*y1center/subject=study type=un s;
repeated/group=arm;
run;

title "Study specific variances";
** study specific variances estimated;
proc mixed data=ipd method = reml;
class study group;
model y2= y1center study study*y1center group/s cl ddfm=betwithin;
random groupcenter/subject=study TYPE=un s;
repeated/group=study;
run;

title "Study specific variances, with interaction of baseline with treament, separating within and across-trial interaction";
** study specific variances estimated;* interaction of baseline with treament added; 
proc mixed data=ipd method = reml;
class study groupc;
model y2= y1center study group study*y1center group*y1center group*meanstudy/s cl ddfm=betwithin;
random groupcenter groupcenter*y1center/subject=study TYPE=un s;
repeated/group=study;
run;

title "Group specific variances";
* group specific variances estimated;
proc mixed data=ipd method = reml;
class study groupc;
model y2= y1center study study*y1center groupcenter/s cl ddfm=betwithin;
random groupcenter/subject=study type=un s;
repeated/group=groupc;
run;

title "Group specific variances, with interaction of baseline with treament, separating within and across-trial interaction";
* group specific variances estimated; * interaction of baseline with treament added; 
proc mixed data=ipd method = reml;
class study groupc;
model y2= y1center study study*y1center group group*y1center group*meanstudy/s cl ddfm=betwithin;
random groupcenter groupcenter*y1center /subject=study type=un s;
repeated/group=groupc;
run;

title "One residual variance";
** one residual variance;
proc mixed data=ipd method = reml;
class study groupc;
model y2= y1center study study*y1center group/s cl ddfm=betwithin;
random groupcenter /subject=study type=un s;
run;

title "One residual variance, with interaction of baseline with treament, separating within and across-trial interaction";
proc mixed data=ipd method = reml;
class study groupc;
model y2= y1center study group y1center*study group*y1center group*meanstudy/s cl ddfm=betwithin;
random groupcenter groupcenter*y1center/subject=study type=un s;
run;

*--------------------------------------------------------;
*  Random study models             
*--------------------------------------------------------;

title "Arm/study specific variances";
proc mixed data=ipd method=reml;
class study arm;
model y2= y1center group/s cl ddfm=betwithin;
random int groupcenter y1center/subject=study type=un s;
repeated/group=arm;
run;

* memory problems when type = un for random components. Therefore type = vc;
title "Arm/study specific variances, with interaction of baseline with treament, separating within and across-trial interaction";
proc mixed data=ipd method=reml;
class study arm;
model y2= y1center group group*y1center group*meanstudy/s cl ddfm=betwithin;
random int groupcenter groupcenter*y1center y1center /subject=study type=vc s;
repeated/group=arm;
run;

title "Study specific variances";
proc mixed data=ipd method = reml;
class study arm;
model y2= y1center group/s cl ddfm=contain;
random int groupcenter y1center/subject=study type=un s;
repeated/group=study;
run;

* memory problems when type = un for random components. Therefore type = vc;
title "Study specific variances, with interaction of baseline with treament, separating within and across-trial interaction";
proc mixed data=ipd method = reml;
class study arm;
model y2= y1center group group*y1center group*meanstudy/s cl ddfm=betwithin;
random int groupcenter groupcenter*y1center y1center/subject=study type=vc s;
repeated/group=study;
run;

title "group specific variances, random study model";
proc mixed data=ipd method = reml;
class study groupc;
model y2= y1center group/s cl ddfm=betwithin;
random int groupcenter y1center/subject=study type=un s;
repeated/group=groupc;
run;

* memory problems when type = un for random components. Therefore type = vc;
title "Group specific variances, with interaction of baseline with treament, separating within and across-trial interaction";
proc mixed data=ipd method = reml;
class study groupc;
model y2= y1center group group*y1center group*meanstudy/s cl ddfm=betwithin;
random int groupcenter groupcenter*y1center y1center/subject=study type=vc s;
repeated/group=groupc;
run;

title "One residual variance";
proc mixed data=ipd method = reml;
class study groupc;
model y2= y1center group/s cl ddfm=betwithin;
random int groupcenter y1center/subject=study type=un s;
run;

title "One residual variance, random study model with interaction of baseline with treament";
proc mixed data=ipd method = reml;
class study groupc;
model y2= y1center group group*y1center group*meanstudy/s cl ddfm=betwithin;
random int groupcenter groupcenter*y1center y1center/subject=study type=un s;
run;

*------------------------------------------------------------------------------
*  Two-stage ANCOVA approach using the pseudo IPD    
*------------------------------------------------------------------------------;

title "Two stage ANCOVA";
proc sort data=ipd; by study;
* separate ancovas per study, regress y2 on y1 and group, save regression coefficients;
ods output ParameterEstimates = effect_est;
proc glm data=ipd plots=none;
		 model y2= y1 group/ solution; *ANCOVA with interaction;
		 by study;
run;		 
data effect_est; set effect_est(keep= study Parameter Estimate StdErr); 
if Parameter="group"; 
run;
* variances of the effect estimates, needed to perform random effects meta analysis in SAS;
data effect_est; set effect_est;
row =_n_; col=_n_;value=StdErr*StdErr;
proc print data=effect_est; run;

* pool the estimated effects in a random effects meta analysis;
* the gdata command holds variances at known values;
proc mixed data = effect_est order=data;
class study;
model estimate= /  solution cl;
random study/gdata=effect_est s;
repeated diag;
run;

title "Two stage ANCOVA with interaction treatment by baseline";
ods output ParameterEstimates = effect_est;
proc glm data=ipd plots=none;
		 model y2= y1 group y1*group/ solution; *ANCOVA with interaction;
		 by study;
run;		 
data effect_est; set effect_est(keep= study Parameter Estimate StdErr); 
if Parameter="y1*group"; 
run;
* variances of the effect estimates, needed to perform random effects meta analysis in SAS;
data effect_est; set effect_est;
row =_n_; col=_n_;value=StdErr*StdErr;
proc print data=effect_est; run;
* pool the estimated effects in a random effects meta analysis;
* the gdata command holds variances at known values;
proc mixed data = effect_est order=data;
class study;
model estimate= /  solution cl;
random study/gdata=effect_est s;
repeated diag;
run;
proc print data=effect_est; var estimate stderr; run;
