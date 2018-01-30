#/bin/sh
#apach-hive cmd is include in path! 
#
#一次性执行所有的查询
#
#输出参数：
#	数据库大小（G）：例如10，100，1000等等
#

#原始sql文件的目录
#sql_dir=/home/hadoop/download/hive-testbench/sample-queries-tpcds
sql_dir=.
error=my-query-$1G.error
log=my-query-$1G.log
#目录是否存在
if [ ! -d "$sql_dir" ]; then
	date >> $error 
	echo $sql_dir"目录不存在" >> $error
	exit 1
fi

#查询结果所在目录
sql_result=/home/hadoop/download/hive-testbench/sample-queries-tpcds/my-query-result
#创建目录
mkdir -p $sql_result

#对每一个sql文件进行查询
for entry in `ls query*.sql`; do
	#记录进度
	date >> $log
	echo $entry"开始执行" >> $log
	#构造新的查询语句
	new_sql_file=$sql_result/$1G-$entry
	new_sql_result=$sql_result/$1G-$entry.result
    	echo "use tpcds_bin_partitioned_orc_$1;" > $new_sql_file
	cat $sql_dir/$entry >> $new_sql_file
	#执行hive查询
	echo "开始执行查询"$new_sql_file > $new_sql_result
	date >> $new_sql_result
	hive -S -f $new_sql_file >> $new_sql_result
	#判断是否执行成功 
	if [ $?  -ne 0  ]; then 
		echo "查询new_sql_file失败" >> $new_sql_result
		mv $new_sql_result $sql_result/$1G-$entry.error
		date >>  $sql_result/$1G-$entry.error
	else
		echo "查询new_sql_file成功" >> $new_sql_result
		date >> $new_sql_result
	fi
	#记录进度
        date >> $log
        echo $entry"执行完成" >> $log
done
