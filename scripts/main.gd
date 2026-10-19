extends Node

@export var mob_scene: PackedScene
var score = 0
var difficulty = 1.0
var game_time = 0.0
var mobs_killed = 0
var is_game_over = false
var game_started = false

func new_game():
	get_tree().call_group("mobs", "queue_free")
	
	score = 0
	difficulty = 1.0
	game_time = 0.0
	mobs_killed = 0
	is_game_over = false
	game_started = false
	
	$ScoreTimer.stop()
	$MobTimer.stop()
	$StartTimer.stop()
	
	$Player.hide()
	$HUD.reset_game()
	$HUD.show_message("Нажмите Начать!")
	$HUD/StartButton.show()
	$Music.stop()

func start_game_actual():
	game_started = true
	is_game_over = false
	score = 0
	difficulty = 1.0
	game_time = 0.0
	mobs_killed = 0
	
	$Player.start($StartPosition.position)
	$Player.show()
	$StartTimer.start()
	$Music.play()
	$MobTimer.wait_time = 2.0
	$HUD.show_message("Готовься!")

func game_over() -> void:
	if is_game_over:
		return
	is_game_over = true
	game_started = false
	$ScoreTimer.stop()
	$MobTimer.stop()
	$Music.stop()
	$DeathSound.play()
	$HUD.game_stats.time_survived = game_time
	$HUD.game_stats.mobs_killed = mobs_killed
	$HUD.show_game_over()

func _process(delta: float) -> void:
	if game_started and not is_game_over and $ScoreTimer.time_left > 0:
		game_time += delta

func _on_start_timer_timeout() -> void:
	if game_started:
		$MobTimer.start()
		$ScoreTimer.start()

func _on_score_timer_timeout() -> void:
	if not game_started or is_game_over:
		return
	score += 1
	$HUD.update_score(score)
	if score % 5 == 0:
		difficulty += 0.2
		$HUD.update_difficulty(difficulty)
		$MobTimer.wait_time = max(0.5, 2.0 / difficulty)
		if not is_game_over:
			$HUD.show_message("Уровень " + str(int(difficulty * 10) / 10))

func _on_mob_timer_timeout() -> void:
	if not game_started or is_game_over or not mob_scene:
		return
	var mob = mob_scene.instantiate()
	var mob_spawn_location = $MobPath/MobSpawnLocation
	var direction = mob_spawn_location.rotation + PI / 2
	var base_speed = randf_range(150.0, 250.0) * difficulty
	var velocity = Vector2(base_speed, 0.0)
	mob_spawn_location.progress_ratio = randf()
	mob.position = mob_spawn_location.position
	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction
	mob.linear_velocity = velocity.rotated(direction)
	mob.add_to_group("mobs")
	add_child(mob)

func _ready():
	new_game()

func _on_hud_start_game() -> void:
	start_game_actual()
