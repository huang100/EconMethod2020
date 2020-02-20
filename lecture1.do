// 打开文件

sysuse auto, clear

// 数据描述

des

des make price

// 描述统计

summarize

// stata里很多命令可以简写。例如，summarize可以简写成sum，输出是一样的。类似的，describe可以写成des
sum

//描述特定变量
sum mpg weigh

//给出更详细的统计量, 可以使用sum的选项detail(简写为d).此选项可以给出给多的统计量
sum mpg weigh, d

//显示前十行数据
list in 1/10

//看一下数据是如何变码的
codebook

// 如果不知道某个命令的功能，可以使用help查询.例如，我想查询sum这个命令的功能，可以输入
help summarize

// 生成变量
gen price_center = price - 6165.257 //减去均值

gen cheap = price < 6165.257 //根据price < 6165.257这个条件是否正确生成一个虚拟变量

// 我们来看一下这两个变量是否符合我们的预期

sum price_center

/* 均值为0 */

tab cheap

/* cheap是一个取值为0或者1的虚拟变量 */

// 使用逻辑与&合并条件
gen lightcheap=(price<4000)&(weight<3000)

// 自己检查一下，是否符合预期
list lightcheap price weight in 1/10

// Stata有若干系统变量，我们可以调用。在进行一些数据分析时，我们需要使用这些变量。为了区分我们自己定义的变量
// 系统变量以下划线“_”开头
// 这里，我们看一下如何使用系统变量 _n 生成ID
gen new_id = _n
list new_id price trunk in 1/5

drop new_id

// 更改变量取值
replace price = 0

sum price

// 生序/降序排列数据
sysuse auto, clear //因为我们之前更改了数据，这里我们重新载入
sort price
list price in 1/5

// 批量更改变量取值
recode price (0/6165=1)(6166/16000=0), gen(cheap1) //根据price的范围，生成一个新的分类变量cheap1

// 给变量加标签，便于使用。例如做表时，变量有标签，可以显示标签，读者可以知道指代变量的含义
label var cheap1 "车价分类"

tab cheap1


