libname IPEDS '~/IPEDS';
libname GIT '~/GIT';

proc sql;
 create table GradRatesA as
 select enroll.unitid label="School Identifier",
        enroll.Total as cohort label="Incoming Cohort Size",
        (grad.Total/enroll.Total) as Rate format=percentn8.2 label="Graduation Rate"
 from (select unitid, total
       from ipeds.graduation
       where group eq 'Incoming cohort (minus exclusions)'
      )
        as
       enroll
      inner join
      (select unitid, total
       from ipeds.graduation
       where group eq 'Completers within 150% of normal time'
      )
        as
       grad
      on enroll.unitid eq grad.unitid
 order by enroll.unitid   
      ;
quit;

proc compare base=GradRatesA compare=ipeds.gradrates;
run;

