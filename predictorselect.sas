libname IPEDS '~/IPEDS';
libname GIT '~/GIT';
OPTIONS FMTSEARCH=(IPEDS);
data characteristicsPrd (keep = unitid control iclevel hloffer locale instcat c21enprf cbsatype);
 set ipeds.characteristics;
 by unitid;
run;

proc sql;
 create table AidPrd as
 select unitid, (uagrntn/scfa2) as GrantRate format=percentn8.2, (uagrntt/scfa2) as GrantAvg, 
        (upgrntn/scfa2) as PellRate format=percentn8.2, (ufloann/scfa2) as LoanRate format=percentn8.2, (ufloant/scfa2) as LoanAvg     
 from ipeds.aid
 ;
quit;

data TuitionCostsPrd (keep = unitid tuition1--boardamt);
 set ipeds.tuitionandcosts;
 by unitid;
run;

proc sql;
   create table SalPrd as
   select 
       salaries.unitid, 
       sum(sa09mot) / sum(sa09mct) as AvgSalary, 
       mean(scfa2) / sum(sa09mct) as StuFacRatio format=comma5.1
   from ipeds.salaries 
   inner join ipeds.aid
   on salaries.unitid = aid.unitid
   group by salaries.unitid;
quit;

data ipedsmerged;
 merge  IPEDS.gradrates characteristicsPrd AidPrd tuitioncostsPrd SalPrd;
 by unitid;
run;