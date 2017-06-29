DROP FUNCTION madlibkmeans(num_centroid INTEGER);
DROP FUNCTION clusteringtuning(max_centroid INTEGER);
DROP TABLE IF EXISTS clusteringresult;

CREATE TABLE clusteringresult(
  cluster int,
  iteration int,
  objval float
);

CREATE OR REPLACE FUNCTION madlibkmeans(num_centroid INTEGER) RETURNS INTEGER AS $$
DECLARE
    obj DOUBLE PRECISION;
    ite INTEGER;
BEGIN

    RAISE WARNING 'MadlibKmeans=%', num_centroid;
    DROP TABLE IF EXISTS km_result;

    CREATE TABLE km_result AS
    SELECT * FROM madlib.kmeanspp('sensor_clustering_src', 'data', num_centroid,
                               'madlib.squared_dist_norm2',
                               'madlib.avg', 20, 0.001);
    select into obj, ite objective_fn, num_iterations from km_result;
    insert into clusteringresult values (num_centroid+1000, ite, obj);
    RAISE WARNING 'MadlibKmeans obj=%  ite=%', obj, ite;

    RETURN 1;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION clusteringtuning(max_centroid INTEGER) RETURNS INTEGER AS $$
DECLARE
    lCount INTEGER;
BEGIN

    lCount := 0;

    RAISE WARNING 'ClusteringTuning=%', max_centroid;

    FOR lCount IN 1..max_centroid
    LOOP
        RAISE WARNING 'lCount=% 1', lCount;
        perform madlibkmeans( lCount );
        RAISE WARNING 'lCount=% 2', lCount;
    END LOOP;

    RETURN 0;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION func_hoge( arg_num int ) RETURNS int
AS $$
  DECLARE
    temp_num int;
  BEGIN
    -- 引数に１を足して返却する
    RAISE WARNING 'arg_num=%', arg_num;
    temp_num = arg_num + 1;
    RETURN temp_num;
  END;
$$ LANGUAGE plpgsql;

select clusteringtuning(30);
