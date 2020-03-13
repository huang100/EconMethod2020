// 用宏来替换路径
local ThisLecture "/Users/Huang/Dropbox/研究生课程/2020春季/研究方法/代码"
cd "`ThisLecture'"

// 用宏来替换数值或者字符
clear
set obs 1
local a = 10
local b = 50
gen c = `a'+`b'
display c

// 载入数据
sysuse nlsw88.dta, clear
describe

// Regress wage on demographic characteristics
reg wage age married collgrad

// 使用宏
local indepvar age married collgrad
local depvar wage
reg `depvar' `indepvar'
Question: 两个回归结果是否一样？
// More on macro
local age_above_40 "if age>40"
reg `depvar' `indepvar' `age_above_40'

// Some Stata commands automatically store results in macros
sum wage

return list

display `r(mean)'

// 生成一个去均值的工资变量
gen wage_c = wage - r(mean)
gen wage_d = wage - `r(mean)'

sum wage_c wage_d
reg wage age race collgrad => WRONG
!怎么解释race的系数
codebook race

// Method 1

// 通过generate和replace生成虚拟变量
gen white = 0
replace white = 1 if race==1
// you can do this with a single line:
// gen white = race==1
gen black = 0
replace black = 1 if race==2
gen other = 0
replace other = 1 if race==3

//看一下新生成的变量
sum white black other

// debug
assert white+black+other == 1

// debug
list race white black other in 1/10

// 回归
reg wage black other
Question：解释系数！
drop white black other

// Method 2
//通过分类变量的取值生成多个虚拟变量
tab race, gen(group)

sum group*

rename group1 white
rename group2 black
rename group3 other

reg wage black other

// Method 2
// 使用 “i” 操作符
reg wage i.race

// 共线性
reg wage white black other
Question：为什么black被扔掉？
// 改变参考组
reg wage i.race
Question：参考组是哪一个？怎么解释系数？
reg wage ib3.race

// 交叉项: 穷举
reg wage collgrad#race, allbaselevels
Question: Collgrad取几个值？Race有几个值？两个分类变量的各种交互组合有多少种？
// 区分主效应和交叉项
// var1##var2: i.var1 i.var2 var1#var2
reg wage collgrad##race, allbaselevels
Question： 解释系数。哪些是主效应？哪些是交叉效应？
// without displaying reference levels
reg wage collgrad##race

reg wage i.collgrad##i.race

// 连续变量交叉时前面要加 “c.”
reg wage c.age##race, allbaselevels

// 做图
scatter wage age

// 回归系数
ssc install coefplot

coefplot, drop(_cons) xline(0)


