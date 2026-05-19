extends Node

# Autoload qui centralise l'accès aux autres autoloads.
# Doit être déclaré en dernier dans project.godot pour que les @onready
# trouvent bien les singletons déjà initialisés.

@onready var story_engine: StoryEngineCore = get_node("/root/StoryEngine")
@onready var chapitres: ChapitresDB = get_node("/root/Chapitres")
@onready var contracts: ContractsDB = get_node("/root/Contracts")
@onready var disasters: DisastersDB = get_node("/root/Disasters")
@onready var leaderboard: LeaderboardStore = get_node("/root/Leaderboard")
