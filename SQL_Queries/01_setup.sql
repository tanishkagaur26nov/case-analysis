use rms_project;

create table rms_cases(
	case_id  BIGINT PRIMARY KEY,
    month           VARCHAR(10),
    date_opened     DATE,
    date_closed     DATE,
    fc              VARCHAR(20),
    marketplace     CHAR(2),
    region          CHAR(2),
    root_cause      VARCHAR(255),
    rms_given       VARCHAR(3),
    asin_count      INT,
    rms_amount      DECIMAL(12,2),
    shipment_type   VARCHAR(10),
    carrier         VARCHAR(40),
    re_evaluation   VARCHAR(3),
    approved        VARCHAR(3),
    re_eval_amount  DECIMAL(12,2),
    seller_name     VARCHAR(100)
);

select * from rms_cases;