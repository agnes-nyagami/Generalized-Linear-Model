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

data TuitionCostsPrd (keep =unitid tuition1--boardamt);
 set ipeds.tuitionandcosts;
 by unitid;
run;

proc sql;
 create table TuitionCstsPrd as
 select tuitionandcosts.unitid,
   case when (tuition1-tuition2) ne 0 then 1
        when (tuition1-tuition2) eq 0 then 0
        end
        as InDistrictT, (tuition2-tuition1) as InDistrictTDiff,
   case when (fee1-fee2) ne 0 then 1
        when (fee1-fee2) eq 0 then 0
        end
        as InDistrictF, (fee2-fee1) as InDistrictFDiff,
        tuition2 as InStateT, fee2 as InStateF,
   case when (tuition3-tuition2) ne 0 then 1
        when (tuition3-tuition2) eq 0 then 0
        end
        as OutStateT, (tuition3-tuition2) as OutStateTTDiff,
   case when (fee3-fee2) ne 0 then 1
        when (fee3-fee2) eq 0 then 0
        end
        as OutStateF, (fee3-fee2) as OutStateFDiff, room as housing,
        scfa2 / roomcap as ScaledHousingCap,
   case when board = 3 then 0
        else board
        end as board, 
   case when roomamt eq . then 0
        else roomamt
        end as roomamt,
   case when boardamt eq . then 0
        else boardamt
        end as boardamt
 from IPEDS.tuitionandcosts
 inner join ipeds.aid
 on tuitionandcosts.unitid = aid.unitid;
quit;

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