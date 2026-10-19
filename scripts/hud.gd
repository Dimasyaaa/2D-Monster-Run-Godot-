extends CanvasLayer

signal start_game

@onready var data_manager = get_node("/root/DataManager")

var high_score = 0
var game_stats = {
	"score": 0,
	"time_survived": 0,
	"mobs_killed": 0
}

func _ready():
	if data_manager:
		high_score = data_manager.high_score
	update_high_score_display()
	reset_game()

func reset_game():
	game_stats = {"score": 0, "time_survived": 0, "mobs_killed": 0}
	$ScoreLabel.text = "Счет: 0"
	$DifficultyLabel.text = "Уровень: 1"
	$Message.text = "Нажмите Начать!"
	$Message.show()
	$StartButton.show()

func show_message(text: String) -> void:
	$Message.text = text
	$Message.show()
	$MessageTimer.start()

func show_game_over() -> void:
	var stats_text = "Игра окончена!\nСчет: " + str(game_stats.score)
	if data_manager and data_manager.update_high_score(game_stats.score):
		stats_text += "\nНОВЫЙ РЕКОРД!"
		high_score = game_stats.score
		update_high_score_display()
	show_message(stats_text)
	await $MessageTimer.timeout
	$Message.text = "Начать!"
	$Message.show()
	$StartButton.show()

func update_score(score: int) -> void:
	game_stats.score = score
	$ScoreLabel.text = "Счет: " + str(score)
	if score > high_score:
		high_score = score
		update_high_score_display()

func update_high_score_display() -> void:
	$HighScoreLabel.text = "Рекорд: " + str(high_score)

func update_difficulty(level: float) -> void:
	$DifficultyLabel.text = "Уровень: " + str(level)

func _on_start_button_pressed() -> void:
	$StartButton.hide()
	start_game.emit()

func _on_message_timer_timeout() -> void:
	$Message.hide()
