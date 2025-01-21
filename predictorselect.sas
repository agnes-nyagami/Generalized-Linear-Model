libname IPEDS '~/IPEDS';
libname GIT '~/GIT';
OPTIONS FMTSEARCH=(IPEDS);
data characteristicsPrd (keep = unitid control iclevel hloffer locale instcat c21enprf cbsatype);
 set ipeds.characteristics;
 by unitid;
run;

/**proc format cntlin=ipeds.ipedsformats;
run;**/

proc sql;
 create table AidPrd as
 select unitid, (scfa2/uagrntn) as GrantRate format=percentn8.2, (uagrntt/scfa2) as GrantAvg, 
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
 select salaries.unitid, (sa09mot/sa09mct) as AvgSalary, (scfa2/sa09mct) as StuFacRatio      
 from ipeds.salaries inner join ipeds.aid
 on salaries.unitid eq aid.unitid
 ;
quit;

data ipedsmerged;
 merge  IPEDS.gradrates characteristicsPrd AidPrd tuitioncostsPrd SalPrd;
 by unitid;
run;

PROC SORT DATA= ipedsmerged out=ipedsmerge4dsorted nodupkey;
       by unitid;
run;