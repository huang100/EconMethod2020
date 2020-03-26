// 读入数据
use mus08psidextract.dta, clear

// 变量描述
describe

// 统计描述
summarize

// 数据组织结构
order id t, before(exp)
list id t exp wks occ union in 1/20

// 定义控制变量
global xvars "c.exp occ ind south smsa ms fem c.ed blk"

// 面板数据声明
xtset id t

// 看一下状态转移
xttrans union

// 加入/不加入控制变量
qui reg lwage union i.t, vce(cluster id)
est store pool_m1
qui reg lwage union $xvars i.t, vce(cluster id)
est store pool_m2
esttab pool_m1 pool_m2, se stats(N ll) star(* 0.1 ** 0.05 *** 0.01) ///
    mtitle("Pooled without control var" "Pooled with control var")

// 加入/不加入控制变量
qui xtreg lwage union i.t, re vce(cluster id)
est store re_m1
qui xtreg lwage union $xvars i.t, re vce(cluster id)
est store re_m2
esttab re_m1 re_m2, se stats(N ll) star(* 0.1 ** 0.05 *** 0.01) ///
    mtitle("RE without control var" "RE with control var")

// 模型选择
esttab pool_m1 pool_m2 re_m1 re_m2, se stats(N ll) star(* 0.1 ** 0.05 *** 0.01) ///
    mtitle("Pooled" "Pooled" "RE" "RE")

/*
No fundamental difference between pooled ols and random effect model
*/

// 不加入控制变量
xtreg lwage union i.t, fe vce(cluster id)
est store fe_m1

/*
如何解释t的系数？
*/

// 加入控制变量
xtreg lwage union $xvars i.t, fe vce(cluster id)
est store fe_m2

/*
为什么fem等变量没有了？
*/

// 模型选择
esttab fe_m1 fe_m2, se stats(N ll) star(* 0.1 ** 0.05 *** 0.01) ///
    mtitle("FE without control var" "FE with control var")

/*
1. union的系数是否显著？怎么解释？没影响？样本量？自变量缺少变化？
2. 是否需要加入控制变量？如何影响因果关系？如何影响估计效率？
*/

// 模型选择
esttab pool_m1 pool_m2 re_m1 re_m2 fe_m1 fe_m2, se stats(N ll) star(* 0.1 ** 0.05 *** 0.01) ///
    mtitle("Pooled" "Pooled" "RE" "RE" "FE" "FE")

/*
比较上面几个模型结果，可以得出什么结论？
1. FE 更加稳健 （为什么？）
2. FE 干预变量需要足够的变化，有没有？
*/

// 固定效应下的安慰剂检验 placebo test，也被称为证伪检验 falsfication test
xtreg lwage union F1.union L1.union i.t, fe vce(cluster id)
est store fe_m1

/*
1. 通过滞后项捕捉持续效应 persistent treatment effect
2. 通过前置项捕捉预期效应或者逆因果关系
*/

// 比较FE和RE，Hausman test (见课件，没有太大实际作用)

// 生成个体特征平均值
global xvars1 "exp occ ind south smsa ms fem ed blk"
foreach var of varlist $xvars1 {
    bysort id: egen `var'_ave = mean(`var')
}
/*
谁来讲一下这段程序的logic
*/

// Chamberlain Mundlak RE 随机效应模型
global xvars_ave "exp_ave occ_ave ind_ave south_ave smsa_ave ms_ave fem_ave ed_ave blk_ave"
xtreg lwage union $xvars $xvars_ave i.t, re vce(cluster id)
est store re_m3

// 模型选择
esttab re_m1 re_m2 re_m3, se stats(N ll) star(* 0.1 ** 0.05 *** 0.01) ///
    mtitle("RE without control var" "RE with control var" " Chamberlain Mundlak RE")


