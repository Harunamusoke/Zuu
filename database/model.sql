-- PAY - PROCEDURE
CREATE PROCEDURE `pay_procedure`
(
int_account VARCHAR
(50),
    amount DECIMAL
(9,2),
    provider VARCHAR
(50),
    int_reference VARCHAR
(50),
    mo_reference VARCHAR
(50),
    user_id INT, 
    plan_id TINYINT	
)
BEGIN    
START TRANSACTION;
INSERT INTO payments
    (`payment_id`, `user_id
    `, `plan_id`, `date_created`, `price`, `expiry_date`)
VALUES
(DEFAULT,user_id, plan_id , NOW
()  , amount ,DATE_ADD
( NOW
(),INTERVAL
(
            SELECT period_in_days
FROM plans p
WHERE p.plan_id = plan_id )
DAY )        
);
INSERT INTO sent_status
    ( `payment_id`, `users_id
    `, `sent`)
VALUES
(LAST_INSERT_ID
(), user_id, DEFAULT);
COMMIT;
INSERT INTO payment_sys_success
    ( `payment_id`, `account
    `, `amount`, `provider`, `reference`, `mo_reference`)
    VALUES
(LAST_INSERT_ID
(), int_account, amount, provider, int_reference,mo_reference);
END

-- SENT STATUS PROCEDURE

CREATE  PROCEDURE `sent_user_status`
(user_id INT)
BEGIN
    SELECT
        CONCAT(first_name," ",last_name) AS full_name,
        u.number,
        py.expiry_date,
        SUM(total - sent ) AS remaining
    FROM users u
        JOIN payments py           
	USING(user_id)
        JOIN plans pl           
	USING(plan_id)
        JOIN sent_status ss
        ON ss.payment_id = py.payment_id AND ss.users_id = u.user_id
    WHERE sent < total AND py.expiry_date > NOW() AND u.user_id = user_id;
END

-- CREATE USER FUNCTION 
CREATE FUNCTION
IF NOT EXISTS `create_user`

(firstname VARCHAR
(50), lastname VARCHAR
(50) , number varchar
(50)) RETURNS int
    READS SQL DATA
BEGIN
    INSERT INTO users
    VALUES
        ( DEFAULT, firstname, lastname, number, now() , null );
    RETURN (SELECT last_insert_id() AS id );
END