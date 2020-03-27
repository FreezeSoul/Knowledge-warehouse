#  Django 数据库操作



Django运算表达式与Q对象/F对象

1 模型查询

```
概述:
1 查询集:表示从数据库中获取的对象的集合
2 查询集可以有多个过滤器,通过 逻辑运算符连接
3 过滤器就是一个函数,基于所给的参数限制查询的结果,类似MySQL模糊查询中where语句
4 查询集等同select语句
```

2 查询集

```
特点:
1 查询集通过调用过滤器方进行查询, 查询集经过过滤器筛选后返回新的查询集,可以链式调用
2 惰性执行  创建查询集不会带来任何数据库的访问直到调用数据库才会访问

返回单个数据查询:
get()     返回一个满足条件的对象
         注意:没有找到符合条件的对象,模型类引发异常  模型类.DoesNotExists异常
         如果找到多个对象也会引发异常   模型类.MultipleObjectsReturned
count()   返回查询集中的对象个数
first()   返回第一个查询集对象
last()    返回最后一个查询集对象
exists()  查询集是否有数据,如果有数据返回true

限制查询集:查询集返回的是列表,可以采用下标的方法进行限制,等同于sql中的limit语句
studentList = Student.objects.all()[0:5]

查询集缓存 ： 每个查询集都包含一个缓存,来最小化的对数据库访问。在新建的查询集中,缓存首次为空,第一次对查询             集求值,django会将数据缓存,并返回结果,以后结果直接使用缓存集的数据
```

3 常见过滤器

```
all()       返回所有对象
filter()     filter(键=值,键=值)  且关系
            返回符合条件的数据
            filter(键=值),filter(键=值)
exclude()   过滤掉符合条件数据
order_by()  排序
values()    一条数据就是是一个对象(字典),返回一个列表
```

4 比较运算符

```
(1)概述： 实现where语句,作为filter()  exclude()  get()的参数
   语法： 属性名称__运算符 = 值
   外键： 属性名_id
   转义： 类似like语句,是为了匹配占位,匹配数据中的%,sql中where like '\%'
         filter(sname__contains = '%')
      
(2)常见的比较运算符：
    exact        判断,大小写敏感
                 filter(isDelete=False)
    contains     是否包含,大小写敏感
                stuList = Student.objects.filter(sname__contains ='孙' )
    startswith   以value开头,大小写敏感
                stuList = Student.objects.filter(sname__startswith ='孙' )
    endwith      以value结尾,大小写敏感 
    in   是否包含在范围内    filter(pk__in=[2,4,6,8,10])
 注： 以上四个前面加上i,就表示不区分大小写,iexact,icontains,istartswith,iendswith
    
(3) 其他形式查询
为空判断：
    isnull ，isnotnull   是否为空   filter(sname__isnull=Flase)  
比较运算：
    gt   大于
    gte  大于等于
    lt   小于
    lte  小于等于
    filter(sage_gt=30)年龄大于30
时间查询：
    year/month/day/week_day/hour/minute/second   filter(lastTime__year=2017)
    跨关查询   处理join查询   模型类型__属性名__运算符(可选)
    查询快捷   pk   代表的主键   
```

5 F对象与Q对象

```
常见的聚合函数：
使用aggregate()函数返回聚合函数的值
Avg  Count   Max   Min   sum

from dango.db.models import Max
maxAge = Student.objects.aggregate(Max('sage'))   找出学生年龄最大的

F对象
1 可以使用模型的A属性与B属性进行比较
    from django.db.models  import F,Q
    def grades(request):
    g = Grades.objects.filter(ggirlnum_gt=F('gboynum'))   找到女生人输大于男生人数的班级
2 支持F对象的算术运算  filter(ggirlnum_gt=F('gboynum')+20)
3 F对象的参数可以是跨表字段
    models.Book.objects.filter(bread_num=F(''author_name'))
4 F对象参数如果是date/time,可以进行日期的加减运算:
    models.Book.objects.filter(bpub_date__lt=F('bpub_date') + timedelta(days=5))
    
Q对象
概述    过滤器的方法中的关键字参数,,条件为And模式,采用逻辑或引入Q对象
需求    进行or查询，或查询
解决    使用Q对象

Q对象可以使用&（and）、|（or）操作符组合起来
studentList = Student.objects.filter(Q(pk__lt = 3)|Q(sage__gt=50))  pk_id小于3或年龄大于50岁
models.User.objects.filter(Q(username='老王') & Q(userpass='admin'))   条件与组合
models.User.objects.filter(~Q(username='老王'))   条件非表示取反
可以使用 &（and） |(or)  ~(not) 结合括号进行分组，构造更复杂的Q对象
filter函数可以传递一个或多个Q对象作为位置参数，如果有多个Q对象，这些参数的逻辑为and

下面分享一个综合用法：

 def get(self, request, *args, **kwargs):
        filters = request.GET
        #找出符合customer的数据转成列表
        Qs = [Q(customer=request.user.customer)]
        try:
            if 'limit' in filters:
                limit = abs(int(filters['limit']))
                if limit > 50:
                    limit = 50
            else:
                limit = 15
            start_id = int(filters.get('start_id', 0))
            #添加符合start_id的对象
            Qs.append(Q(id__gt=start_id))
            #添加符合状态的state
            if 'state' in filters:
                Qs.append(Q(state__in=filters['state']))
            else:
                Qs.append(Q(state__in=[0, 1, 2, 3, 4]))
            #添加符合title的数据
            if 'title' in filters:
                Qs.append(Q(title__contains=filters['title']))
        except Exception:
            return params_error({"filters": "过滤参数不合法"})
        
        #通过*Qs，对列表数据同时满足上述情况的数据进行总的帅选，并设置限制集
        sets = Questionnaire.objects.filter(*Qs)[:limit]
```

