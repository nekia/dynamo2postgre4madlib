drop table if exists sensor_clustering_src;
create temp table sensor_clustering_src(
	id int,
	data float[]
);

with sensor as (
	select id, time, stepcounter,
					json_array_elements(rotationdeg) as r
	from dynamoitem
),
accel as (
	select id,
					json_array_elements(accelometer) as a
	from dynamoitem
)
insert into sensor_clustering_src
select id,
				array[
					ret.avg_a, ret.avg_r, ret.avg_p, ret.var_a, ret.var_r, ret.var_r,
					ret.avg_ax, ret.avg_ay, ret.avg_az, ret.var_ax, ret.var_ay, ret.var_az
				]
from (
	select
		sensor.id, time, stepcounter,
		avg(cast(sensor.r->>'Azimuth' as float)) as avg_a, variance(cast(sensor.r->>'Azimuth' as float)) as var_a,
		avg(cast(sensor.r->>'Pitch' as float)) as avg_p, variance(cast(sensor.r->>'Pitch' as float)) as var_p,
		avg(cast(sensor.r->>'Roll' as float)) as avg_r, variance(cast(sensor.r->>'Roll' as float)) as var_r,
		avg(cast(accel.a->>'Axis_x' as float)) as avg_ax, variance(cast(accel.a->>'Axis_x' as float)) as var_ax,
		avg(cast(accel.a->>'Axis_y' as float)) as avg_ay, variance(cast(accel.a->>'Axis_y' as float)) as var_ay,
		avg(cast(accel.a->>'Axis_z' as float)) as avg_az, variance(cast(accel.a->>'Axis_z' as float)) as var_az
	from sensor, accel
	where sensor.id = accel.id
	group by sensor.id, time, stepcounter
) as ret
order by id;
