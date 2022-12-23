################################################################################
# Enhanced Level Balancing - Version 1.0.0
# Created by Manoel Afonso
# Inspired by Umbreon and Joltik code
################################################################################

module EnhancedLevelBalance

    ################################################################################
    # SETTINGS TO THIS SCRIPT
    # - Use value 0 (zero) when you want to disable the evolution type.
    # - Pokemon that evolve by item or level up when MALE or FEMALE, 
    #   like Kirlia and Burmy, does NOT evolve yet by this script.
    # - Pokemon that evolve by level up when hold item, uses
    #   the flag LEVEL_TO_EVOLVE_BY_ITEM to evolve in this script.
    # - Pokemon that evolve by trade WITH ITEM, uses
    #   the flag LEVEL_TO_EVOLVE_BY_TRADE to evolve in this script.
    # - Pokemon that evolve by EVENT, like Kubfu, does NOT evolve by
    #   this script because I decided so.
    # - Pokemon that evolve by BEAUTY, like Feebas, uses
    #   the flag LEVEL_TO_EVOLVE_BY_HAPPINESS to evolve in this script.
    ################################################################################

    DEBUG_MODE = false                          # Turn true if you want show debug messages on console

    WILD_EVOLVE_ON_LEVEL_BALANCE = true         # Turn false to not evolve when level balance
    TRAINER_EVOLVE_ON_LEVEL_BALANCE = true      # Turn false to not evolve when level balance

    LEVEL_TO_EVOLVE_BY_LOCATION = 0             # To monsters that evolve by location, like Golbat
    LEVEL_TO_EVOLVE_BY_HAPPINESS = 20           # To monsters that evolve by happness, like Golbat
    LEVEL_TO_EVOLVE_BY_MOVE = 30                # To monsters that evolve by has move, like Aipom
    LEVEL_TO_EVOLVE_BY_ITEM = 30                # To monsters that evolve by items, like Pikachu
    LEVEL_TO_EVOLVE_BY_TRADE = 40               # To monsters that evolve by trade, like Graveler

    LIGHT = 10                                  # From level 1 to 10
    EASY = 20                                   # From level 11 to 20
    MEDIUM = 30                                 # From level 21 to 30
    HARD = 40                                   # From level 31 to 40
    INSANE = 55                                 # From level 41 to 55
    EXTREME = Settings::MAXIMUM_LEVEL           # From level 56 to MAXIMUM_LEVEL

    ENHANCED_LEVEL_BALANCE_SWITCH = 59          # Switch that turns on Enhanced Level Balance
  
end