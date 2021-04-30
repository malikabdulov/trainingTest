import config
import mysql.connector
import xlsxwriter
from mysql.connector import Error


def create_db_connection():
    connection = mysql.connector.connect(**config.database)

    try:
        connection = mysql.connector.connect(**config.database)
    except Error as e:
        print(f"The error '{e}' occurred")

    return connection


def close_db_connection(cnx, cursor=None):
    if cursor:
        try:
            cursor.close()
        except Error as e:
            print(f"The error '{e}' occurred")

    try:
        cnx.close()
    except Error as e:
        print(f"The error '{e}' occurred")


def get_student_name(telegram_id):
    """
    :param telegram_id: {call.message.from_user.id}
    :return: query result
    """
    cnx = create_db_connection()
    cursor = cnx.cursor()
    try:
        cursor.execute("SELECT student_name FROM users WHERE telegram_id = %s", (telegram_id,))
        result = cursor.fetchone()
        if result:
            return result[0]
        else:
            return None
    except Error as e:
        print(f"def username_is_exist:::Error '{e}' occurred")
        return None
    finally:
        close_db_connection(cnx, cursor)


def update_users(message):
    user_data = {
        'telegram_id': message.from_user.id,
        'telegram_username': message.from_user.username,
        'first_name': message.from_user.first_name,
        'last_name': message.from_user.last_name,
        'student_name': message.text
    }
    cnx = create_db_connection()
    cursor = cnx.cursor()
    exist = get_student_name(user_data['telegram_id'])

    if not exist:
        query = (
            "INSERT INTO users"
            "         (telegram_id,     telegram_username,     first_name,     last_name, student_name)"
            "VALUES (%(telegram_id)s, %(telegram_username)s, %(first_name)s, %(last_name)s, %(student_name)s )"
        )
    else:
        query = (
            "UPDATE users SET "
            "telegram_username = %(telegram_username)s,"
            "first_name = %(first_name)s, "
            "last_name = %(last_name)s, "
            "student_name = %(student_name)s "
            "WHERE telegram_id = %(telegram_id)s "
        )
    try:
        cursor.execute(query, user_data)
    except Error as e:
        print(cursor.statement())
        print(f"def update_users:::Error '{e}' occurred")
    finally:
        close_db_connection(cnx, cursor)


def get_test():
    cnx = create_db_connection()
    cursor = cnx.cursor()
    query = 'SELECT id, name, description FROM tests '
    try:
        cursor.execute(query)
        output = cursor.fetchone()
        return output
    except Error as e:
        print(f"def get_test:::Error '{e}' occurred")
        return False
    finally:
        close_db_connection(cnx, cursor)


def get_question(test_id, row_num=0):
    cnx = create_db_connection()
    cursor = cnx.cursor()
    query = f'SELECT id, question FROM test_questions WHERE test_id = {test_id} LIMIT {row_num}, 1'
    try:
        cursor.execute(query)
        output = cursor.fetchone()
        return output
    except Error as e:
        print(f"def get_question:::Error '{e}' occurred")
        return False
    finally:
        close_db_connection(cnx, cursor)


def get_variants(question_id):
    cnx = create_db_connection()
    cursor = cnx.cursor()
    query = f'SELECT id, variant, is_right_variant FROM test_question_variants WHERE test_question_id = {question_id}'
    try:
        cursor.execute(query)
        output = cursor.fetchall()
        return output
    except Error as e:
        print(f"def get_question:::Error '{e}' occurred")
        return False
    finally:
        close_db_connection(cnx, cursor)


def set_answer(telegram_id, var_id):
    cnx = create_db_connection()
    cursor = cnx.cursor()
    query = (
        "INSERT INTO test_answers "
        "(student_id, variant_id) "
        f"VALUES ((SELECT id FROM users WHERE telegram_id = {telegram_id}), {var_id})"
    )
    try:
        cursor.execute(query)
    except Error as e:
        print(cursor.statement())
        print(f"def set_answer:::Error '{e}' occurred")
    finally:
        close_db_connection(cnx, cursor)


def get_test_results(telegram_id, test_id):
    cnx = create_db_connection()
    cursor = cnx.cursor()
    query = (
        "SELECT SUM(CASE WHEN tqv.is_right_variant = 'Y' THEN 1 ELSE 0 END) "
        "     , SUM(CASE WHEN tqv.is_right_variant = 'N' THEN 1 ELSE 0 END) "
        "     ,( SELECT COUNT(*) FROM test_questions) "
        "FROM test_answers ta "
        "JOIN test_question_variants tqv ON ta.variant_id = tqv.id "
        "JOIN test_questions tq ON tq.id = tqv.test_question_id "
        "JOIN users u ON u.id = ta.student_id "
        "WHERE DATE(ta.created_at) = CURDATE() "
        f"AND tq.test_id = {test_id} "
        f"AND u.telegram_id = {telegram_id} "
    )
    try:
        cursor.execute(query)
        output = cursor.fetchone()
        return output
    except Error as e:
        print(cursor.statement())
        print(f"def set_answer:::Error '{e}' occurred")
        return None
    finally:
        close_db_connection(cnx, cursor)


def get_report(test_id):
    cnx = create_db_connection()
    cursor = cnx.cursor()
    query = (
        "SELECT DATE(ta.created_at) date, u.student_name "
        ", SUM(CASE WHEN tqv.is_right_variant = 'Y' THEN 1 ELSE 0 END) right_answers "
        "FROM test_answers ta "
        "JOIN users u ON u.id = ta.student_id "
        "JOIN test_question_variants tqv ON ta.variant_id = tqv.id "
        "JOIN test_questions tq ON tq.id = tqv.test_question_id "
        f"AND tq.test_id = {test_id} "
        "GROUP BY 1, 2 "
    )
    try:
        cursor.execute(query)
        header = [row[0] for row in cursor.description]
        rows = cursor.fetchall()
        return header, rows
    except Error as e:
        print(cursor.statement())
        print(f"def set_answer:::Error '{e}' occurred")
        return None
    finally:
        close_db_connection(cnx, cursor)


def export_report(test_id):
    # Create an new Excel file and add a worksheet.
    workbook = xlsxwriter.Workbook('Report.xlsx')
    worksheet = workbook.add_worksheet('REPORT')

    # Create style for cells
    header_cell_format = workbook.add_format({'bold': True, 'border': True, 'bg_color': 'yellow'})
    body_cell_format = workbook.add_format({'border': True})
    body_date_format = workbook.add_format({'border': True, 'num_format': 'd mmm yyyy'})

    header, rows = get_report(test_id)

    row_index = 0
    column_index = 0

    for column_name in header:
        worksheet.write(row_index, column_index, column_name, header_cell_format)
        column_index += 1

    row_index += 1
    for row in rows:
        column_index = 0
        for column in row:
            if column_index == 0:
                worksheet.write(row_index, column_index, column, body_date_format)
            else:
                worksheet.write(row_index, column_index, column, body_cell_format)
            column_index += 1
        row_index += 1

    worksheet.set_column('A:C', 20)

    print(str(row_index) + ' rows written successfully to ' + workbook.filename)

    # Closing workbook
    workbook.close()


def already_taken(telegram_id, test_id):
    cnx = create_db_connection()
    cursor = cnx.cursor()
    query = (
        "SELECT ta.id "
        "FROM test_answers ta "
        "JOIN users u ON u.id = ta.student_id "
        "JOIN test_question_variants tqv ON tqv.id = ta.variant_id "        
        "JOIN test_questions tq ON tq.id = tqv.test_question_id "
        "WHERE DATE(ta.created_at) = CURDATE() "
        f"AND tq.test_id = {test_id} "
        f"AND u.telegram_id = {telegram_id} "
    )
    try:
        cursor.execute(query)
        output = cursor.fetchone()
        return output
    except Error as e:
        print(cursor.statement())
        print(f"def set_answer:::Error '{e}' occurred")
        return None
    finally:
        close_db_connection(cnx, cursor)


def check_first_answer_time(test_id, telegram_id):
    cnx = create_db_connection()
    cursor = cnx.cursor()
    query = (
        "SELECT ta.created_at "
        "FROM test_answers ta "
        "JOIN users u ON u.id = ta.student_id "
        "JOIN test_question_variants tqv ON tqv.id = ta.variant_id "
        "JOIN test_questions tq ON tq.id = tqv.test_question_id "
        "WHERE DATE(ta.created_at) = CURDATE() "
        f"AND tq.test_id = {test_id} "
        f"AND u.telegram_id = {telegram_id} "
        "ORDER BY ta.variant_id "
        "LIMIT 1 "
    )
    try:
        cursor.execute(query)
        output = cursor.fetchone()
        try:
            return output[0]
        except:
            return None
    except Error as e:
        print(cursor.statement())
        print(f"def set_answer:::Error '{e}' occurred")
        return None
    finally:
        close_db_connection(cnx, cursor)


if __name__ == '__main__':
    import datetime
    r = check_first_answer_time(1, 413974882)
    diff = datetime.datetime.now() - r
    print(diff.seconds/60)

