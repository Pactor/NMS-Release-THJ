# Dump the 'nms' database for distribution (attach the .gz to a GitHub Release).
# CONTENT-ONLY: every table's SCHEMA is included (so the server has all tables), but the
# data of account / character / guild / inventory / trader / logs / per-player tables is
# EXCLUDED, so setters-up start with a clean server (no real accounts, chars, or password hashes).
# Usage:  .\dump_db.ps1  [-User peq] [-Password peqpass] [-Db nms]
param(
  [string]$User = "peq",
  [string]$Password = "peqpass",
  [string]$Db = "nms",
  [string]$MariaBin = "C:\Program Files\MariaDB 11.6\bin",
  [string]$OutDir = ".\dump"
)
$ErrorActionPreference = "Stop"
$dump = Join-Path $MariaBin "mysqldump.exe"
New-Item -ItemType Directory -Force $OutDir | Out-Null
$stamp = Get-Date -Format "yyyyMMdd"
$sql = Join-Path $OutDir "$Db-content-$stamp.sql"
$gz  = "$sql.gz"

# Player / account / log tables: DATA excluded (schema still included via the --no-data pass).
$exclude = @(
  "account","account_alt_currency","account_flags","account_ip","account_kill_counts","account_rewards",
  "bugs","petitions","buyer","buyer_buy_lines","buyer_trade_items","trader","trader_audit",
  "char_recipe_list","claude_teleport","data_buckets","discovered_items","friends","mail",
  "group_id","group_leaders","raid_details","raid_leaders","raid_members",
  "guilds","guild_bank","guild_members","guild_permissions","guild_ranks","guild_relations","guild_tributes",
  "instance_list","instance_list_player","inventory","inventory_snapshots","inventory_versions",
  "ip_exemptions","keyring","login_accounts","login_api_tokens","login_server_admins","login_world_servers",
  "nms_waypoints_account","nms_waypoints_character","player_titlesets","sharedbank","sharedbank_migration_temp",
  "spire_user_event_log",
  "character_aa_disabled","character_activities","character_alternate_abilities","character_alt_currency",
  "character_auras","character_bandolier","character_bind","character_buffs","character_corpses",
  "character_corpse_items","character_currency","character_data","character_data_extra","character_disciplines",
  "character_dynamic_aa_timers","character_enabledtasks","character_evolving_items","character_expedition_lockouts",
  "character_exp_modifiers","character_inspect_messages","character_instance_safereturns","character_item_recast",
  "character_languages","character_leadership_abilities","character_material","character_memmed_spells",
  "character_parcels","character_parcels_containers","character_peqzone_flags","character_pet_buffs",
  "character_pet_command_states","character_pet_info","character_pet_inventory","character_pet_name",
  "character_potionbelt","character_skills","character_spells","character_stats_record","character_tasks",
  "character_task_timers","character_tribute",
  "player_event_aa_purchase","player_event_killed_named_npc","player_event_killed_npc","player_event_killed_raid_npc",
  "player_event_logs","player_event_log_settings","player_event_loot_items","player_event_merchant_purchase",
  "player_event_merchant_sell","player_event_npc_handin","player_event_npc_handin_entries","player_event_speech",
  "player_event_trade","player_event_trade_entries",
  "qs_merchant_transaction_record","qs_merchant_transaction_record_entries","qs_player_aa_rate_hourly",
  "qs_player_delete_record","qs_player_delete_record_entries","qs_player_events","qs_player_handin_record",
  "qs_player_handin_record_entries","qs_player_move_record","qs_player_move_record_entries",
  "qs_player_npc_kill_record","qs_player_npc_kill_record_entries","qs_player_speech","qs_player_trade_record",
  "qs_player_trade_record_entries"
)
$ignore = $exclude | ForEach-Object { "--ignore-table=$Db.$_" }

Write-Host "Pass 1/2: full schema (all tables, no data)..."
& $dump "-u$User" "-p$Password" --no-data --routines --events $Db > $sql
if ($LASTEXITCODE -ne 0) { throw "schema dump failed ($LASTEXITCODE)" }

Write-Host "Pass 2/2: content data (excluding $($exclude.Count) player/account/log tables)..."
& $dump "-u$User" "-p$Password" --no-create-info --skip-triggers --single-transaction @ignore $Db >> $sql
if ($LASTEXITCODE -ne 0) { throw "data dump failed ($LASTEXITCODE)" }

Write-Host "Compressing -> $gz ..."
$in = [System.IO.File]::OpenRead($sql); $out = [System.IO.File]::Create($gz)
$gzip = New-Object System.IO.Compression.GzipStream($out, [System.IO.Compression.CompressionLevel]::Optimal)
$in.CopyTo($gzip); $gzip.Dispose(); $out.Dispose(); $in.Dispose(); Remove-Item $sql
Write-Host "Done: $gz  ($([math]::Round((Get-Item $gz).Length/1MB,1)) MB)"
Write-Host "Content-only (no accounts/characters). Attach to a GitHub Release; do not commit."
