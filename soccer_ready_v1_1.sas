
data players_skills;
set work.just_player_attributes;
year=(datepart(date));
format year date9.;
run;

data players_skills_1;
set players_skills;
year1=year(year);
run;

proc freq data=players_skills_1;
tables year1;
run;


data 
y2007
y2008
y2009
y2010
y2011
y2012
y2013
y2014
y2015
y2016
;
set players_skills_1;
if year1=2007 then output y2007;
if year1=2008 then output y2008;
if year1=2009 then output y2009;
if year1=2010 then output y2010;
if year1=2011 then output y2011;
if year1=2012 then output y2012;
if year1=2013 then output y2013;
if year1=2014 then output y2014;
if year1=2015 then output y2015;
if year1=2016 then output y2016;
run;

proc sort data=y2016;
by player_fifa_api_id year;
run;

data y2016;
set y2016;
by player_fifa_api_id year;
if last.player_fifa_api_id then output;
run;

proc sql;
create table y2016_model as
select
a.*,
b.Potential as Potential_2018,
b.Overall as Overall_2018
from
y2016 as a
left join
FULL_FIFA18_DATA as b
on
a.player_fifa_api_id=b.ID;
quit;


proc means data=y2016_model n nmiss;
var Potential_2018 Overall_2018;
run;

proc sql;
create table y2016_model_name as
select
a.*,
b.*
from
y2016_model as a
left join
PLAYER_REF as b
on
a.player_fifa_api_id=b.player_fifa_api_id;
quit;

data y2016_model_name;
set y2016_model_name; 
birthday_new=(datepart(birthday));
format birthday_new date9.;
run;

data y2016_model_name_filt;
set y2016_model_name;
/*if birthday_new<"01jan1989"d then delete;*/
run;


proc means data=y2016_model_name_filt n nmiss;
var Potential_2018 Overall_2018;
run;
proc sort data=work.forwards out=forwards_samples nodupkey;
by Player_ID;
run;


proc sql;
create table forwards_samples as
select
a.Position,
a.club,
a.age,
a.nationality,
a.eur_value,
a.eur_wage,
a.eur_release_clause,
b.*
from
forwards_samples  as a
left join
y2016_model_name_filt as b
on
a.Player_ID=b.player_fifa_api_id;
quit;
data forwards_samples;
set forwards_samples;
if player_name="" then delete;
run;


data forwards_samples_flag;
set forwards_samples;
if Overall_2018>(overall_rating+0.05*overall_rating) then flag_overall=1;else flag_overall=0;
run;
proc contents data= forwards_samples_flag;
run;

proc freq data=forwards_samples_flag;
tables flag_overall;
run;


proc surveyselect data=forwards_samples_flag out=dev_forwards method=srs samprate=.3 outall noprint;
run; 

proc freq data=dev_forwards;
tables Selected*flag_overall;
run;

data dev_forwards_soccer;
set dev_forwards;
where Selected=0;
run;


data val_forwards_soccer;
set dev_forwards;
where Selected=1;
run;



data y2016_model_name_filt_flag;
set dev_forwards_soccer;
if flag_overall=. then delete;
run;

proc freq data=y2016_model_name_filt_flag;
tables flag_overall;
run;

proc contents data=forwards_samples_flag;
run;

data forwards_sample_flag_bin;
set forwards_samples_flag;
if acceleration<55 then bin_acceleration=1;
if acceleration>=55 and acceleration<63 then bin_acceleration=2;
if acceleration>=63 and acceleration<77 then bin_acceleration=3;
if acceleration>=77 and acceleration<79 then bin_acceleration=4;
if acceleration>=79 and acceleration<80 then bin_acceleration=5;
if acceleration>=80 and acceleration<83 then bin_acceleration=6;
if acceleration>=83 then  bin_acceleration=7;

if age<22 then bin_age=1;
if age>=22 and age<24 then bin_age=2;
if age>=24 and age<28 then bin_age=3;
if age>=28 and age<33 then bin_age=4;
if age>=33 then bin_age=5;

if aggression<46 then bin_aggression=1;
if aggression>=46 and aggression<58 then bin_aggression=2;
if aggression>=58 and aggression<60 then bin_aggression=3;
if aggression>=60 and aggression<66 then bin_aggression=4;
if aggression>=66 and aggression<70 then bin_aggression=5;
if aggression>=70 then bin_aggression=6;

if agility<68 then bin_agility=1;
if agility>=68 and agility<78 then bin_agility=2;
if agility>=78 then bin_agility=3;

if balance<48 then bin_balance=1;
if balance>=48 and balance<56 then bin_balance=2;
if balance>=56 and balance<60 then bin_balance=3;
if balance>=60 and balance<65 then bin_balance=4;
if balance>=65 and balance<70 then bin_balance=5;
if balance>=70 then bin_balance=6;

if ball_control<64 then bin_ball_control=1;
if ball_control>=64 and ball_control<70 then bin_ball_control=2;
if ball_control>=70 and ball_control<81 then bin_ball_control=3;
if ball_control>=81 then bin_ball_control=4;

if crossing<40 then bin_crossing=1;
if crossing>=40 and crossing<58 then bin_crossing=2;
if crossing>=58 and crossing<62 then bin_crossing=3;
if crossing>=62 then bin_crossing=4;

if curve<43 then bin_curve=1;
if curve>=43 and curve<55 then bin_curve=2;
if curve>=55 and curve<59 then bin_curve=3;
if curve>=59  then bin_curve=4;

if dribbling<62 then bin_dribbling=1;
if dribbling>=62 and dribbling<68 then bin_dribbling=2;
if dribbling>=68 and dribbling<70 then bin_dribbling=3;
if dribbling>=70 and dribbling<72 then bin_dribbling=4;
if dribbling>=72 and dribbling<77 then bin_dribbling=5;
if dribbling>=77 then bin_dribbling=6;

if finishing<65 then bin_finishing=1;
if finishing>=65 and finishing<75 then bin_finishing=2;
if finishing>=75 and finishing<83 then bin_finishing=3;
if finishing>=83 then bin_finishing=4;

if heading_accuracy<48 then bin_heading_accuracy=1;
if heading_accuracy>=48 and heading_accuracy<68 then bin_heading_accuracy=2;
if heading_accuracy>=68 and heading_accuracy<73 then bin_heading_accuracy=3;
if heading_accuracy>=73 then bin_heading_accuracy=4;


if height<176 then bin_height=1;
if height>=176 and height<178 then bin_height=2;
if height>=178 and height<182 then bin_height=3;
if height>=182 and height<192 then bin_height=4;
if height>=192 then bin_height=5;


if interceptions<20 then bin_interceptions=1;
if interceptions>=20 and interceptions<31 then bin_interceptions=2;
if interceptions>=31 and interceptions<43 then bin_interceptions=3;
if interceptions>=43 then bin_interceptions=4;

if jumping<56 then bin_jumping=1;
if jumping>=56 and jumping<61 then bin_jumping=2;
if jumping>=61 and jumping<69 then bin_jumping=3;
if jumping>=69 and jumping<73 then bin_jumping=4;
if jumping>=73 and jumping<86 then bin_jumping=5;
if jumping>=86 then bin_jumping=6;

if long_passing<41 then bin_long_passing=1;
if long_passing>=41 and long_passing<53 then bin_long_passing=2;
if long_passing>=53 and long_passing<72 then bin_long_passing=3;
if long_passing>=72 then bin_long_passing=4;

if long_shots<56 then bin_long_shots=1;
if long_shots>=56 and long_shots<64 then bin_long_shots=2;
if long_shots>=64 and long_shots<67 then bin_long_shots=3;
if long_shots>=67 then bin_long_shots=4;

if marking<17 then bin_marking=1;
if marking>=17 and marking<19 then bin_marking=2;
if marking>=19 and marking<26 then bin_marking=3;
if marking>=26 and marking<31 then bin_marking=4;
if marking>=31 then bin_marking=5;

if penalties<66 then bin_penalties=1;
if penalties>=66 and penalties<68 then bin_penalties=2;
if penalties>=68 and penalties<75 then bin_penalties=3;
if penalties>=75 then bin_penalties=4;

if positioning<64 then bin_positioning=1;
if positioning>=64 and positioning<77 then bin_positioning=2;
if positioning>=77 and positioning<83 then bin_positioning=3;
if positioning>=83 then bin_positioning=4;

if reactions<60 then bin_reactions=1;
if reactions>=60 and reactions<71 then bin_reactions=2;
if reactions>=71 and reactions<74 then bin_reactions=3;
if reactions>=74 then bin_reactions=4;

if short_passing<53 then bin_short_passing=1;
if short_passing>=53 and short_passing<59 then bin_short_passing=2;
if short_passing>=59 and short_passing<65 then bin_short_passing=3;
if short_passing>=65 and short_passing<67 then bin_short_passing=4;
if short_passing>=67 and short_passing<72 then bin_short_passing=5;
if short_passing>=72 then bin_short_passing=6;

if shot_power<63 then bin_shot_power=1;
if shot_power>=63 and shot_power<72 then bin_shot_power=2;
if shot_power>=72 and shot_power<76 then bin_shot_power=3;
if shot_power>=76 then bin_shot_power=4;

if sliding_tackle<16 then bin_sliding_tackle=1;
if sliding_tackle>=16 and sliding_tackle<19 then bin_sliding_tackle=2;
if sliding_tackle>=19 and sliding_tackle<36 then bin_sliding_tackle=3;
if sliding_tackle>=36 and sliding_tackle<46 then bin_sliding_tackle=4;
if sliding_tackle>=46 then bin_sliding_tackle=5;

if sprint_speed<56 then bin_sprint_speed=1;
if sprint_speed>=56 and sprint_speed<66 then bin_sprint_speed=2;
if sprint_speed>=66 and sprint_speed<90 then bin_sprint_speed=3;
if sprint_speed>=90 then bin_sprint_speed=4;

if stamina<61 then bin_stamina=1;
if stamina>=61 and stamina<68 then bin_stamina=2;
if stamina>=68 and stamina<71 then bin_stamina=3;
if stamina>=71 and stamina<73 then bin_stamina=4;
if stamina>=73 and stamina<79 then bin_stamina=5;
if stamina>=79 then bin_stamina=6;

if standing_tackle<16 then bin_standing_tackle=1;
if standing_tackle>=16 and standing_tackle<30 then bin_standing_tackle=2;
if standing_tackle>=30 and standing_tackle<34 then bin_standing_tackle=3;
if standing_tackle>=34 and standing_tackle<37 then bin_standing_tackle=4;
if standing_tackle>=37 and standing_tackle<49 then bin_standing_tackle=5;
if standing_tackle>=49 then bin_standing_tackle=6;

if strength<66 then bin_strength=1;
if strength>=66 and standing_tackle<70 then bin_strength=2;
if strength>=70 and standing_tackle<76 then bin_strength=3;
if strength>=76 and standing_tackle<78 then bin_strength=4;
if strength>=78 and standing_tackle<82 then bin_strength=5;
if strength>=82 and standing_tackle<86 then bin_strength=6;
if strength>=86 then bin_strength=7;

if vision<58 then bin_vision=1;
if vision>=58 and vision<77 then bin_vision=2;
if vision>=77 then bin_vision=3;

if volleys<59 then bin_volleys=1;
if volleys>=59 and volleys<61 then bin_volleys=2;
if volleys>=61 and volleys<70 then bin_volleys=3;
if volleys>=70 and volleys<74 then bin_volleys=4;
if volleys>=74 then bin_volleys=5;

run;


data dev_forwards_soccer_bin;
set dev_forwards_soccer;
if acceleration<55 then bin_acceleration=1;
if acceleration>=55 and acceleration<63 then bin_acceleration=2;
if acceleration>=63 and acceleration<77 then bin_acceleration=3;
if acceleration>=77 and acceleration<79 then bin_acceleration=4;
if acceleration>=79 and acceleration<80 then bin_acceleration=5;
if acceleration>=80 and acceleration<83 then bin_acceleration=6;
if acceleration>=83 then  bin_acceleration=7;

if age<22 then bin_age=1;
if age>=22 and age<24 then bin_age=2;
if age>=24 and age<28 then bin_age=3;
if age>=28 and age<33 then bin_age=4;
if age>=33 then bin_age=5;

if aggression<46 then bin_aggression=1;
if aggression>=46 and aggression<58 then bin_aggression=2;
if aggression>=58 and aggression<60 then bin_aggression=3;
if aggression>=60 and aggression<66 then bin_aggression=4;
if aggression>=66 and aggression<70 then bin_aggression=5;
if aggression>=70 then bin_aggression=6;

if agility<68 then bin_agility=1;
if agility>=68 and agility<78 then bin_agility=2;
if agility>=78 then bin_agility=3;

if balance<48 then bin_balance=1;
if balance>=48 and balance<56 then bin_balance=2;
if balance>=56 and balance<60 then bin_balance=3;
if balance>=60 and balance<65 then bin_balance=4;
if balance>=65 and balance<70 then bin_balance=5;
if balance>=70 then bin_balance=6;

if ball_control<64 then bin_ball_control=1;
if ball_control>=64 and ball_control<70 then bin_ball_control=2;
if ball_control>=70 and ball_control<81 then bin_ball_control=3;
if ball_control>=81 then bin_ball_control=4;

if crossing<40 then bin_crossing=1;
if crossing>=40 and crossing<58 then bin_crossing=2;
if crossing>=58 and crossing<62 then bin_crossing=3;
if crossing>=62 then bin_crossing=4;

if curve<43 then bin_curve=1;
if curve>=43 and curve<55 then bin_curve=2;
if curve>=55 and curve<59 then bin_curve=3;
if curve>=59  then bin_curve=4;

if dribbling<62 then bin_dribbling=1;
if dribbling>=62 and dribbling<68 then bin_dribbling=2;
if dribbling>=68 and dribbling<70 then bin_dribbling=3;
if dribbling>=70 and dribbling<72 then bin_dribbling=4;
if dribbling>=72 and dribbling<77 then bin_dribbling=5;
if dribbling>=77 then bin_dribbling=6;

if finishing<65 then bin_finishing=1;
if finishing>=65 and finishing<75 then bin_finishing=2;
if finishing>=75 and finishing<83 then bin_finishing=3;
if finishing>=83 then bin_finishing=4;

if heading_accuracy<48 then bin_heading_accuracy=1;
if heading_accuracy>=48 and heading_accuracy<68 then bin_heading_accuracy=2;
if heading_accuracy>=68 and heading_accuracy<73 then bin_heading_accuracy=3;
if heading_accuracy>=73 then bin_heading_accuracy=4;


if height<176 then bin_height=1;
if height>=176 and height<178 then bin_height=2;
if height>=178 and height<182 then bin_height=3;
if height>=182 and height<192 then bin_height=4;
if height>=192 then bin_height=5;


if interceptions<20 then bin_interceptions=1;
if interceptions>=20 and interceptions<31 then bin_interceptions=2;
if interceptions>=31 and interceptions<43 then bin_interceptions=3;
if interceptions>=43 then bin_interceptions=4;

if jumping<56 then bin_jumping=1;
if jumping>=56 and jumping<61 then bin_jumping=2;
if jumping>=61 and jumping<69 then bin_jumping=3;
if jumping>=69 and jumping<73 then bin_jumping=4;
if jumping>=73 and jumping<86 then bin_jumping=5;
if jumping>=86 then bin_jumping=6;

if long_passing<41 then bin_long_passing=1;
if long_passing>=41 and long_passing<53 then bin_long_passing=2;
if long_passing>=53 and long_passing<72 then bin_long_passing=3;
if long_passing>=72 then bin_long_passing=4;

if long_shots<56 then bin_long_shots=1;
if long_shots>=56 and long_shots<64 then bin_long_shots=2;
if long_shots>=64 and long_shots<67 then bin_long_shots=3;
if long_shots>=67 then bin_long_shots=4;

if marking<17 then bin_marking=1;
if marking>=17 and marking<19 then bin_marking=2;
if marking>=19 and marking<26 then bin_marking=3;
if marking>=26 and marking<31 then bin_marking=4;
if marking>=31 then bin_marking=5;

if penalties<66 then bin_penalties=1;
if penalties>=66 and penalties<68 then bin_penalties=2;
if penalties>=68 and penalties<75 then bin_penalties=3;
if penalties>=75 then bin_penalties=4;

if positioning<64 then bin_positioning=1;
if positioning>=64 and positioning<77 then bin_positioning=2;
if positioning>=77 and positioning<83 then bin_positioning=3;
if positioning>=83 then bin_positioning=4;

if reactions<60 then bin_reactions=1;
if reactions>=60 and reactions<71 then bin_reactions=2;
if reactions>=71 and reactions<74 then bin_reactions=3;
if reactions>=74 then bin_reactions=4;

if short_passing<53 then bin_short_passing=1;
if short_passing>=53 and short_passing<59 then bin_short_passing=2;
if short_passing>=59 and short_passing<65 then bin_short_passing=3;
if short_passing>=65 and short_passing<67 then bin_short_passing=4;
if short_passing>=67 and short_passing<72 then bin_short_passing=5;
if short_passing>=72 then bin_short_passing=6;

if shot_power<63 then bin_shot_power=1;
if shot_power>=63 and shot_power<72 then bin_shot_power=2;
if shot_power>=72 and shot_power<76 then bin_shot_power=3;
if shot_power>=76 then bin_shot_power=4;

if sliding_tackle<16 then bin_sliding_tackle=1;
if sliding_tackle>=16 and sliding_tackle<19 then bin_sliding_tackle=2;
if sliding_tackle>=19 and sliding_tackle<36 then bin_sliding_tackle=3;
if sliding_tackle>=36 and sliding_tackle<46 then bin_sliding_tackle=4;
if sliding_tackle>=46 then bin_sliding_tackle=5;

if sprint_speed<56 then bin_sprint_speed=1;
if sprint_speed>=56 and sprint_speed<66 then bin_sprint_speed=2;
if sprint_speed>=66 and sprint_speed<90 then bin_sprint_speed=3;
if sprint_speed>=90 then bin_sprint_speed=4;

if stamina<61 then bin_stamina=1;
if stamina>=61 and stamina<68 then bin_stamina=2;
if stamina>=68 and stamina<71 then bin_stamina=3;
if stamina>=71 and stamina<73 then bin_stamina=4;
if stamina>=73 and stamina<79 then bin_stamina=5;
if stamina>=79 then bin_stamina=6;

if standing_tackle<16 then bin_standing_tackle=1;
if standing_tackle>=16 and standing_tackle<30 then bin_standing_tackle=2;
if standing_tackle>=30 and standing_tackle<34 then bin_standing_tackle=3;
if standing_tackle>=34 and standing_tackle<37 then bin_standing_tackle=4;
if standing_tackle>=37 and standing_tackle<49 then bin_standing_tackle=5;
if standing_tackle>=49 then bin_standing_tackle=6;

if strength<66 then bin_strength=1;
if strength>=66 and standing_tackle<70 then bin_strength=2;
if strength>=70 and standing_tackle<76 then bin_strength=3;
if strength>=76 and standing_tackle<78 then bin_strength=4;
if strength>=78 and standing_tackle<82 then bin_strength=5;
if strength>=82 and standing_tackle<86 then bin_strength=6;
if strength>=86 then bin_strength=7;

if vision<58 then bin_vision=1;
if vision>=58 and vision<77 then bin_vision=2;
if vision>=77 then bin_vision=3;

if volleys<59 then bin_volleys=1;
if volleys>=59 and volleys<61 then bin_volleys=2;
if volleys>=61 and volleys<70 then bin_volleys=3;
if volleys>=70 and volleys<74 then bin_volleys=4;
if volleys>=74 then bin_volleys=5;

run;


data val_forwards_soccer;
set dev_forwards;
where Selected=1;
run;
ods noproctitle;
ods graphics / imagemap=on;

proc logistic data=FORWARDS_SAMPLE_FLAG_BIN;
	model flag_overall(event='1')=bin_acceleration bin_age bin_aggression 
		bin_agility bin_balance bin_ball_control bin_crossing bin_curve bin_dribbling 
		bin_finishing bin_heading_accuracy bin_height bin_interceptions bin_jumping 
		bin_long_passing bin_long_shots bin_marking bin_penalties bin_positioning 
		bin_reactions bin_short_passing bin_shot_power bin_sliding_tackle 
		bin_sprint_speed bin_stamina bin_standing_tackle bin_strength bin_vision 
		bin_volleys / link=logit selection=stepwise slentry=0.05 slstay=0.05 
		hierarchy=single technique=fisher;
	code;
run;

/*---------------------model*/

 *****************************************;
 ** SAS Scoring Code for PROC Logistic;
 *****************************************;
 data dev_forwards_soccer_bin_model;
 set dev_forwards_soccer_bin;
 length I_flag_overall $ 12;
 label I_flag_overall = 'Into: flag_overall' ;
 label U_flag_overall = 'Unnormalized Into: flag_overall' ;
 
 label P_flag_overall1 = 'Predicted: flag_overall=1' ;
 label P_flag_overall0 = 'Predicted: flag_overall=0' ;
 
 drop _LMR_BAD;
 _LMR_BAD=0;
 
 *** Check interval variables for missing values;
 if nmiss(bin_age,bin_balance,bin_heading_accuracy,bin_stamina,bin_vision) 
         then do;
    _LMR_BAD=1;
    goto _SKIP_000;
 end;
 
 *** Compute Linear Predictors;
 drop _LP0;
 _LP0 = 0;
 
 *** Effect: bin_age;
 _LP0 = _LP0 + (-0.78070282223509) * bin_age;
 *** Effect: bin_balance;
 _LP0 = _LP0 + (-0.21785764826594) * bin_balance;
 *** Effect: bin_heading_accuracy;
 _LP0 = _LP0 + (-0.4601536566658) * bin_heading_accuracy;
 *** Effect: bin_stamina;
 _LP0 = _LP0 + (0.13717680343346) * bin_stamina;
 *** Effect: bin_vision;
 _LP0 = _LP0 + (-1.04352714977584) * bin_vision;
 
 *** Predicted values;
 _TEMP = 3.99691344369863  + _LP0;
 if (_TEMP < 0) then do;
    _TEMP = exp(_TEMP);
    _P0 = _TEMP / (1 + _TEMP);
 end;
 else _P0 = 1 / (1 + exp(-_TEMP));
 _P1 = 1.0 - _P0;
 P_flag_overall1 = _P0;
 _MAXP = _P0;
 _IY = 1;
 P_flag_overall0 = _P1;
 if (_P1 >  _MAXP + 1E-8) then do;
    _MAXP = _P1;
    _IY = 2;
 end;
 select( _IY );
    when (1) do;
       I_flag_overall = '1' ;
       U_flag_overall = 1;
    end;
    when (2) do;
       I_flag_overall = '0' ;
       U_flag_overall = 0;
    end;
    otherwise do;
       I_flag_overall = '';
       U_flag_overall = .;
    end;
 end;
 _SKIP_000:
 if _LMR_BAD = 1 then do;
 I_flag_overall = '';
 U_flag_overall = .;
 P_flag_overall1 = .;
 P_flag_overall0 = .;
 end;
 run;


data data2019;
set work.data;
heading_accuracy=HeadingAccuracy;
run;

proc freq data=data2019;
tables Position;
run;

data data2019;
set data2019;
if Position in ("CAM", "CF", "CM","LAM", "LF","LM", "LS","LW","RAM", "RF","RM","RS","RW","ST","") then output;;
run;

data data2019_bin;
set data2019;
if age<22 then bin_age=1;
if age>=22 and age<24 then bin_age=2;
if age>=24 and age<28 then bin_age=3;
if age>=28 and age<33 then bin_age=4;
if age>=33 then bin_age=5;

if balance<48 then bin_balance=1;
if balance>=48 and balance<56 then bin_balance=2;
if balance>=56 and balance<60 then bin_balance=3;
if balance>=60 and balance<65 then bin_balance=4;
if balance>=65 and balance<70 then bin_balance=5;
if balance>=70 then bin_balance=6;


if heading_accuracy<48 then bin_heading_accuracy=1;
if heading_accuracy>=48 and heading_accuracy<68 then bin_heading_accuracy=2;
if heading_accuracy>=68 and heading_accuracy<73 then bin_heading_accuracy=3;
if heading_accuracy>=73 then bin_heading_accuracy=4;


if stamina<61 then bin_stamina=1;
if stamina>=61 and stamina<68 then bin_stamina=2;
if stamina>=68 and stamina<71 then bin_stamina=3;
if stamina>=71 and stamina<73 then bin_stamina=4;
if stamina>=73 and stamina<79 then bin_stamina=5;
if stamina>=79 then bin_stamina=6;

if vision<58 then bin_vision=1;
if vision>=58 and vision<77 then bin_vision=2;
if vision>=77 then bin_vision=3;
run;



data data2019_bin_result;
set data2019_bin;
 *****************************************;
 ** SAS Scoring Code for PROC Logistic;
 *****************************************;

 length I_flag_overall $ 12;
 label I_flag_overall = 'Into: flag_overall' ;
 label U_flag_overall = 'Unnormalized Into: flag_overall' ;
 
 label P_flag_overall1 = 'Predicted: flag_overall=1' ;
 label P_flag_overall0 = 'Predicted: flag_overall=0' ;
 
 drop _LMR_BAD;
 _LMR_BAD=0;
 
 *** Check interval variables for missing values;
 if nmiss(bin_age,bin_balance,bin_heading_accuracy,bin_stamina,bin_vision) 
         then do;
    _LMR_BAD=1;
    goto _SKIP_000;
 end;
 
 *** Compute Linear Predictors;
 drop _LP0;
 _LP0 = 0;
 
 *** Effect: bin_age;
 _LP0 = _LP0 + (-0.78070282223509) * bin_age;
 *** Effect: bin_balance;
 _LP0 = _LP0 + (-0.21785764826594) * bin_balance;
 *** Effect: bin_heading_accuracy;
 _LP0 = _LP0 + (-0.4601536566658) * bin_heading_accuracy;
 *** Effect: bin_stamina;
 _LP0 = _LP0 + (0.13717680343346) * bin_stamina;
 *** Effect: bin_vision;
 _LP0 = _LP0 + (-1.04352714977584) * bin_vision;
 
 *** Predicted values;
 _TEMP = 3.99691344369863  + _LP0;
 if (_TEMP < 0) then do;
    _TEMP = exp(_TEMP);
    _P0 = _TEMP / (1 + _TEMP);
 end;
 else _P0 = 1 / (1 + exp(-_TEMP));
 _P1 = 1.0 - _P0;
 P_flag_overall1 = _P0;
 _MAXP = _P0;
 _IY = 1;
 P_flag_overall0 = _P1;
 if (_P1 >  _MAXP + 1E-8) then do;
    _MAXP = _P1;
    _IY = 2;
 end;
 select( _IY );
    when (1) do;
       I_flag_overall = '1' ;
       U_flag_overall = 1;
    end;
    when (2) do;
       I_flag_overall = '0' ;
       U_flag_overall = 0;
    end;
    otherwise do;
       I_flag_overall = '';
       U_flag_overall = .;
    end;
 end;
 _SKIP_000:
 if _LMR_BAD = 1 then do;
 I_flag_overall = '';
 U_flag_overall = .;
 P_flag_overall1 = .;
 P_flag_overall0 = .;
 end;
 run;
/*
DATA data2019_bin_result_VALUE;
SET data2019_bin_result;
K=FIND(value,"K");
M=FIND(value,"M");
num = prxchange('s/(\D*)(\d*)(\D*)/$2/',-1,VALUE);
wnum= prxchange('s/(\D*)(\d*)(\D*)/$2/',-1,wage);
run;

DATA data2019_bin_result_VALUE;
set data2019_bin_result_VALUE;
if K>0 then value_euro=num*1000;else value_euro=num*1000000;
run;

data data2019_bin_result_VALUE;
set  data2019_bin_result_VALUE;
wage_eur=wnum*1000;
run;
ˆ110.5M


/*
Age
Balance
HeadingAccuracy
Stamina
Vision
*/