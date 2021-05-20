CREATE OR REPLACE FUNCTION CHECK_PASSWORD() RETURNS TRIGGER AS
$$
BEGIN
    IF((NEW.password ~ '[A-Z]') AND (NEW.password ~ '[0-9]')) THEN
        RETURN NEW;
    ELSE
        RAISE EXCEPTION 'Password harus terdapat minimal 1 huruf kapital dan 1 angka';
	END IF;
END;
$$
LANGUAGE PLPGSQL;


CREATE TRIGGER PASSWORD_VIOLATION
BEFORE INSERT ON AKUN_PENGGUNA
FOR EACH ROW
EXECUTE PROCEDURE CHECK_PASSWORD();