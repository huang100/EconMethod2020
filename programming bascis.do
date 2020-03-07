/*
Stata programming basics
Zhiyong HUANG, zhiyonghuang@swufe.edu.cn
Ver: 2020 March

Module 1: MLE
Module 2: GMM
Module 3: Postestimation
*/

/****************************/
/*    linear regression     */
/****************************/
// Load data
sysuse nlsw88.dta, clear
des

// Likelihood
capture program drop lfols
program lfols
	args lnf xb lnsigma
	local y "$ML_y1"
	quietly replace `lnf' = ln(normalden(`y', `xb',exp(`lnsigma')))
end 

// Optimization
ml model lf lfols (xb: wage = age i.race collgrad) (lnsigma:)
ml maximize
display exp([lnsigma]_cons)

// Make a comparison with build-in reg command
reg wage age i.race collgrad

* No wonder! We've got exactly the same outcomes

/**********************************/
/*   logit regression   */
/**********************************/
capture program drop lflogit
program lflogit
	args lnf xb
	local y "$ML_y1"
	quietly replace `lnf' = ln(  invlogit(`xb')) if `y'==1
	quietly replace `lnf' = ln(1-invlogit(`xb')) if `y'==0
end

ml model lf lflogit (union = age i.race collgrad)
ml maximize

logit union age i.race collgrad


/*************************/
/*   probit regression   */
/*************************/

capture program drop lfprobit
program lfprobit
	args lnf xb
	local y "$ML_y1"
	quietly replace `lnf' = ln(  normal(`xb')) if `y'==1
	quietly replace `lnf' = ln(1-normal(`xb')) if `y'==0
end

ml model lf lfprobit (union = age i.race collgrad)
ml maximize
 

/*************************************/
/*   ordered logit regression   */
/*************************************/
// Load data
webuse nhanes2f, clear
des
tab health

// ML
capture program drop lfologit
program lfologit
	args lnf xb a1 a2 a3 a4
	local y "$ML_y1"
	quietly replace `lnf' =  ln(  invlogit(`a1'-`xb')) if `y'==1
	quietly replace `lnf' =  ln(  invlogit(`a2'-`xb') -invlogit(`a1'-`xb'))  if `y'==2
	quietly replace `lnf' =  ln(  invlogit(`a3'-`xb') -invlogit(`a2'-`xb'))  if `y'==3
	quietly replace `lnf' =  ln(  invlogit(`a4'-`xb') -invlogit(`a3'-`xb'))  if `y'==4
	quietly replace `lnf' =  ln(1-invlogit(`a4'-`xb')) if `y'==5
end

ml model lf lfologit (health = female black age, nocons) /cut1 /cut2 /cut3 /cut4
ml maximize

// Compare with build-in ologit
ologit health female black age

/*
1. Why no constant? Other ways to identify?
2. What is ivlogit for? Use help to find out...
*/

 
/*********************************/
/*   ordered probit regression   */
/*********************************/

capture program drop lfoprobit
program lfoprobit
	args lnf xb a1 a2 a3 a4
	local y "$ML_y1"
	quietly replace `lnf' =  ln(  normal(`a1'-`xb')) if `y'==1
	quietly replace `lnf' =  ln(  normal(`a2'-`xb') -normal(`a1'-`xb'))  if `y'==2
	quietly replace `lnf' =  ln(  normal(`a3'-`xb') -normal(`a2'-`xb'))  if `y'==3
	quietly replace `lnf' =  ln(  normal(`a4'-`xb') -normal(`a3'-`xb'))  if `y'==4
	quietly replace `lnf' =  ln(1-normal(`a4'-`xb')) if `y'==5
end

ml model lf lfoprobit (health = female black age, nocons) /cut1 /cut2 /cut3 /cut4
ml maximize
 
/***************************************/
/*   multinomial logit regression   */
/***************************************/
gen morb = 1 if heartatk == 0 & diabetes == 0
replace morb = 2 if heartatk == 1 & diabetes == 0
replace morb = 3 if heartatk == 0 & diabetes == 1
replace morb = 4 if heartatk == 1 & diabetes == 1
tab morb

capture program drop lfmlogit
program lfmlogit
	args lnf xb1 xb2 xb3
	local y "$ML_y1"
	tempvar p1 p2 p3 p4
	quietly {
		gen double `p1' = 1/(1+exp(`xb1')+exp(`xb2')+exp(`xb3'))
		gen double `p2' = exp(`xb1')/(1+exp(`xb1')+exp(`xb2')+exp(`xb3'))
		gen double `p3' = exp(`xb2')/(1+exp(`xb1')+exp(`xb2')+exp(`xb3'))
		gen double `p4' = exp(`xb3')/(1+exp(`xb1')+exp(`xb2')+exp(`xb3'))
		replace `lnf' = (`y' == 1)*ln(`p1') + (`y' == 2)*ln(`p2') + (`y' == 3)*ln(`p3') + (`y' == 4)*ln(`p4')
	}
end

ml model lf lfmlogit (eq1: morb = female black age) (eq2: female black age) (eq3: female black age)
ml maximize

// Compare with build-in function ologit
ologit morb female black age

/**************************/
/*   poisson regression   */
/**************************/

// Load data
use http://www.stata-press.com/data/r14/docvisits ,clear
des
tab docvis

// ML
capture program drop lfpois
program lfpois
	args lnf theta1
	tempvar lnyfact mu
	local y "$ML_y1"
	generate double `lnyfact' =lnfactorial(`y')
	generate double `mu' = exp(`theta1')
	quietly replace `lnf' = -`mu' + `y'*`theta1' - `lnyfact'
end
 
ml model lf lfpois (docvis = age female income chronic private), vce(robust)
ml maximize
 
/************************************/ 
/*   negative binomial regression   */
/************************************/
 
capture program drop lfnb
program lfnb
	args lnf theta1 a
	tempvar mu
	local y "$ML_y1"
	generate double `mu' = exp(`theta1')
	quietly replace `lnf' = lngamma(`y'+ (1/`a'))-lngamma((1/`a')) ///
		   - lnfactorial(`y') - (`y'+(1/`a'))*ln(1+`a'*`mu')      ///
		   + `y'*ln(`a') + `y'*ln(`mu')
end
 
ml model lf lfnb (docvis = age female income chronic private)(a:)
ml maximize
