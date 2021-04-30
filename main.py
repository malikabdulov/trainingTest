import telebot
from telebot.types import InlineKeyboardMarkup, InlineKeyboardButton, ReplyKeyboardMarkup, ReplyKeyboardRemove
import database as sql
import config
import re
import time
from datetime import datetime

bot = telebot.TeleBot(token=config.potatobot['token'], parse_mode='Markdown')


@bot.message_handler(commands=['start'])
def start_message(message):
    st_name = sql.get_student_name(message.from_user.id)
    if st_name:
        hi_name = st_name
    else:
        hi_name = message.from_user.first_name
    text = f'Привет, *{hi_name}*!\nДобро пожаловать! Я бот-тренер!\n\n_Используй команду /help_'
    chat_id = message.chat.id
    bot.send_message(chat_id=chat_id, text=text)


@bot.message_handler(commands=['help'])
def help_message(message):
    key_test = InlineKeyboardButton(text='Начать тест', callback_data='start_test')
    markup_inline = InlineKeyboardMarkup()
    markup_inline.add(key_test)
    if message.from_user.id in config.admins:
        key_report = InlineKeyboardButton(text='Получить статистику', callback_data='get_report')
        markup_inline.add(key_report)
    text = f'Available commands\n/start\n/help'
    chat_id = message.chat.id
    bot.send_message(chat_id=chat_id, text=text, reply_markup=markup_inline)


@bot.callback_query_handler(func=lambda call: call.data == 'start_test')
def get_name(call):
    print('Callback:', call.data)
    telegram_id = call.from_user.id
    is_name_exists = sql.get_student_name(telegram_id)
    chat_id = call.message.chat.id
    msg_id = call.message.id
    text = call.message.text
    if is_name_exists:
        test = sql.get_test()
        test_id = test[0]
        taken = sql.already_taken(telegram_id, test_id)
        if taken:
            text = 'Вы уже сдавали тест сегодня.'
            bot.edit_message_text(message_id=msg_id, chat_id=chat_id, text=text)
        else:
            bot.edit_message_text(message_id=msg_id, chat_id=chat_id, text=text)
            send_questions(call.message, test_id)
    else:
        text = f'Напиши свое имя.'
        msg = bot.edit_message_text(message_id=msg_id, chat_id=chat_id, text=text)
        bot.register_next_step_handler(msg, start_test)


@bot.callback_query_handler(func=lambda call: call.data == 'get_report')
def send_report(call):
    print('Callback:', call.data)
    chat_id = call.message.chat.id
    sql.export_report(1)
    time.sleep(1.5)
    f = open('Report.xlsx', 'rb')
    bot.send_document(chat_id=chat_id, data=f)


@bot.callback_query_handler(func=lambda call: re.match(pattern='v_id=\d+row_num=\d+test_id=\d+', string=call.data))
def answer_handler(call):
    print('Callback:', call.data)
    chat_id = call.message.chat.id
    msg_id = call.message.id
    telegram_id = call.from_user.id
    pattern = re.findall(pattern='\d+', string=call.data)
    var_id = int(pattern[0])
    row_num = int(pattern[1])
    test_id = int(pattern[2])
    text = call.message.text + '\n*ANSWERED*'
    bot.edit_message_text(message_id=msg_id, chat_id=chat_id, text=text)
    sql.set_answer(telegram_id, var_id)
    send_questions(call.message, test_id, row_num+1)


def start_test(message):
    sql.update_users(message)
    test = sql.get_test()
    test_id = test[0]
    test_name = test[1]
    description = test[2]
    chat_id = message.chat.id
    text = f'*{test_name}*\n_{description}_'
    bot.send_message(chat_id=chat_id, text=text)
    send_questions(message, test_id)


def send_questions(message, test_id, row_num=0):
    telegram_id = message.chat.id
    chat_id = message.chat.id
    time_end = False
    if row_num != 0:
        start_time = sql.check_first_answer_time(test_id, telegram_id)
        diff = datetime.now() - start_time
        diff_minutes = diff.seconds/60
        if diff_minutes >= config.minutes_to_test:
            time_end = True
    if time_end:
        bot.send_message(chat_id=chat_id, text='Время закончилось, глянем на твои результаты.')
        bot.send_sticker(chat_id=chat_id,
                         data='CAACAgIAAxkBAAECMg5geq9IrghFjdKmFmEbjTigXmmGeAACMAADNraOCPwLBo-827_NHwQ')
        results = sql.get_test_results(telegram_id, test_id)
        correct = results[0]
        incorrect = results[1]
        num_questions = results[2]
        text = f'Correct answers - {correct}\nIncorrect answers - {incorrect}\nNumber of questions - {num_questions}'
        bot.send_message(chat_id=chat_id, text=text)
    else:
        chat_id = message.chat.id
        telegram_id = message.chat.id
        question = sql.get_question(test_id=test_id, row_num=row_num)
        if question:
            q_id = question[0]
            q_text = question[1]
            variants = sql.get_variants(question_id=q_id)
            markup_inline = InlineKeyboardMarkup()
            text = q_text + '\n'
            for variant in variants:
                v_id = variant[0]
                v_text = variant[1]
                text = text + f'\n• {v_text}'
                markup_inline.add(InlineKeyboardButton(text=f'{v_text}',
                                                       callback_data=f'v_id={v_id}row_num={row_num}test_id={test_id}'))
            bot.send_message(chat_id=chat_id, text=text, reply_markup=markup_inline)
        else:
            bot.send_message(chat_id=chat_id, text='Тест завершен, глянем на твои результаты.')
            bot.send_sticker(chat_id=chat_id, data='CAACAgIAAxkBAAECMg5geq9IrghFjdKmFmEbjTigXmmGeAACMAADNraOCPwLBo-827_NHwQ')
            results = sql.get_test_results(telegram_id, test_id)
            correct = results[0]
            incorrect = results[1]
            num_questions = results[2]
            text = f'Correct answers - {correct}\nIncorrect answers - {incorrect}\nNumber of questions - {num_questions}'
            bot.send_message(chat_id=chat_id, text=text)


if __name__ == '__main__':
    print('Bot is running')
    try:
        bot.polling(none_stop=True, interval=0)
    except Exception as e:
        print('Occurred:', e)
