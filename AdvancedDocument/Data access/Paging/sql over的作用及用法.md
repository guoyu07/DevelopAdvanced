﻿[sql over的作用及用法 ](http://www.cnblogs.com/xiayang/articles/1886372.html)

over不能单独使用，要和分析函数：rank(),dense_rank(),row_number()等一起使用。
其参数：over（partition by columnname1 order by columnname2）
含义：按columname1指定的字段进行分组排序，或者说按字段columnname1的值进行分组排序。
例如：employees表中，有两个部门的记录：department_id ＝10和20
select department_id，rank（） over（partition by department_id order by salary) from employees就是指在部门10中进行薪水的排名，在部门20中进行薪水排名。如果是partition by org_id，则是在整个公司内进行排名。

以下是个人见解：

sql中的over函数和row_numbert()函数配合使用，可生成行号。可对某一列的值进行排序，对于相同值的数据行进行分组排序。

执行语句：select row_number() over(order by AID DESC) as rowid,* from bb
