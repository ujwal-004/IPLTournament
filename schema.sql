CREATE DATABASE IF NOT EXISTS ipl_tournament
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE ipl_tournament;

CREATE TABLE IF NOT EXISTS users (
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(80) NOT NULL UNIQUE,
  password_hash VARCHAR(100) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS teams (
  team_id INT AUTO_INCREMENT PRIMARY KEY,
  team_name VARCHAR(100) NOT NULL UNIQUE,
  coach VARCHAR(100),
  owner VARCHAR(100),
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS players (
  player_id INT AUTO_INCREMENT PRIMARY KEY,
  player_name VARCHAR(100) NOT NULL,
  role VARCHAR(60),
  team_id INT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY ix_players_team (team_id),
  CONSTRAINT fk_players_team FOREIGN KEY (team_id) REFERENCES teams(team_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS matches (
  match_id INT AUTO_INCREMENT PRIMARY KEY,
  team1_id INT NOT NULL,
  team2_id INT NOT NULL,
  winner_team_id INT NULL,
  match_date DATE NOT NULL,
  venue VARCHAR(150),
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT chk_match_teams CHECK (team1_id <> team2_id),
  CONSTRAINT fk_matches_team1 FOREIGN KEY (team1_id) REFERENCES teams(team_id),
  CONSTRAINT fk_matches_team2 FOREIGN KEY (team2_id) REFERENCES teams(team_id),
  CONSTRAINT fk_matches_winner FOREIGN KEY (winner_team_id) REFERENCES teams(team_id)
) ENGINE=InnoDB;
