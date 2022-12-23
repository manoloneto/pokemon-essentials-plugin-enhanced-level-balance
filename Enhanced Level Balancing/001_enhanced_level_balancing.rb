################################################################################
# Enhanced Level Balancing - Version 1.0.0
# Created by Manoel Afonso
# Inspired by Umbreon and Joltik code
################################################################################

module EnhancedLevelBalance

  ################################################################################
  # FUNCTIONS TO WILD AND TRAINER BATTLE
  ################################################################################

  EventHandlers.add(:on_wild_pokemon_created, :enhanced_level_balance_wild,
    proc { |pokemon|
      if $game_switches && $game_switches[EnhancedLevelBalance::ENHANCED_LEVEL_BALANCE_SWITCH]
        newLevel = getNewLevelToOpponent()
        pokemon.level = newLevel

        if EnhancedLevelBalance::WILD_EVOLVE_ON_LEVEL_BALANCE
          currentSpecies = evolveMonsterIfApplicable(pokemon.species, newLevel)
        else
          currentSpecies = getSpecies(pokemon.species)
        end
        
        pokemon.name = currentSpecies.name
        pokemon.species = currentSpecies
        pokemon.calc_stats
        pokemon.reset_moves
      end
    }
  )

  EventHandlers.add(:on_trainer_load, :enhanced_level_balance_trainer,
    proc { |trainer|
      if $game_switches && $game_switches[EnhancedLevelBalance::ENHANCED_LEVEL_BALANCE_SWITCH]
        party = trainer.party
        for i in 0...party.length
          newLevel = getNewLevelToOpponent()
          party[i].level = newLevel

          if EnhancedLevelBalance::TRAINER_EVOLVE_ON_LEVEL_BALANCE
            currentSpecies = evolveMonsterIfApplicable(party[i].species, newLevel)
          else
            currentSpecies = getSpecies(party[i].species)
          end

          party[i].name = currentSpecies.name
          party[i].species = currentSpecies
          party[i].calc_stats
          party[i].reset_moves
        end 
      end
    }
  )

  ################################################################################
  # UTILITIES FUCTIONS TO THIS SCRIPT WORKS
  ################################################################################

  def self.evolveMonsterIfApplicable(species, level)
    # Get first species from the current monster
    currentSpecies = getSpecies(species).get_baby_species

    debugMessage("Monster selected: #{currentSpecies.name} level #{level}\n")

    loop do # evolve monster
      evolutions = getSpecies(currentSpecies).get_evolutions
      if evolutions.length > 0
        newSpecies = getEvolvedSpecies(evolutions[rand(evolutions.length - 1)], currentSpecies, level)
        if newSpecies == currentSpecies
          break
        else
          currentSpecies = newSpecies
        end
      else
        break
      end
    end

    debugMessage("Set monster species to #{currentSpecies.name} level #{level}\n\n---\n\n")
    return currentSpecies
  end

  def self.getEvolvedSpecies(evolution, currentSpecies, newLevel)
    species = evolution[0] 
    method  = evolution[1] 
    target  = evolution[2]

    debugMessage("Evolution selected: #{species} by #{method} #{target}")

    returnNewSpecies = false

    case method
      when :Level, 
           :AttackGreater, 
           :DefenseGreater, 
           :AtkDefEqual, 
           :Silcoon, 
           :Cascoon, 
           :Ninjask, 
           :Shedinja,
           :LevelDarkInParty,
           :LevelDay,
           :LevelNight,
           :LevelRain
        returnNewSpecies = true if newLevel >= target 
      when :Item, 
           :NightHoldItem,
           :DayHoldItem
        returnNewSpecies = true if newLevel >= LEVEL_TO_EVOLVE_BY_ITEM && LEVEL_TO_EVOLVE_BY_ITEM > 0
      when :Happiness, 
           :HappinessMoveType, 
           :HappinessDay, 
           :HappinessNight,
           :Beauty
        returnNewSpecies = true if newLevel >= LEVEL_TO_EVOLVE_BY_HAPPINESS && LEVEL_TO_EVOLVE_BY_HAPPINESS > 0
      when :Trade, 
           :TradeItem,
           :TradeSpecies
        returnNewSpecies = true if newLevel >= LEVEL_TO_EVOLVE_BY_TRADE && LEVEL_TO_EVOLVE_BY_TRADE > 0
      when :HasMove,
           :HasInParty
        returnNewSpecies = true if newLevel >= LEVEL_TO_EVOLVE_BY_MOVE && LEVEL_TO_EVOLVE_BY_MOVE > 0
      when :LocationFlag
        returnNewSpecies = true if newLevel >= LEVEL_TO_EVOLVE_BY_LOCATION && LEVEL_TO_EVOLVE_BY_LOCATION > 0
      else # Another type of evolution
        returnNewSpecies = false 
    end

    if returnNewSpecies
      debugMessage("#{currentSpecies} evolved to #{species}\n")
      return getSpecies(species)
    else 
      debugMessage("Monster not evolved...\n")
      return currentSpecies
    end
  end
  
  def self.calcDifficulty
    difficulties = [LIGHT, EASY, MEDIUM, HARD, INSANE, EXTREME]
    badges = $player.badge_count
    balance = pbBalancedLevel($player.party)
    higherLevel = getHigherPartyLevel
    average = (badges * 30 + 3 * balance + 4 * higherLevel) / 10
    for i in 0...difficulties.length
      if average <= difficulties[i]
        return difficulties[i] # Return the current difficulty
      end
    end
      return LIGHT # Just for errors
  end

  def self.getHigherPartyLevel
    higherLevel = 0
    for poke in $player.party
      higherLevel = poke.level if poke.level > higherLevel 
    end
    return higherLevel
  end

  def self.getNewLevelToOpponent(isTrainer = false)
    difficulty = calcDifficulty
    if isTrainer
      newLevel = getNewLevelToTrainer(difficulty)
    else
      newLevel = getNewLevelToWild(difficulty)
    end 
    newLevel = 1 if newLevel < 1
    newLevel = Settings::MAXIMUM_LEVEL if newLevel > Settings::MAXIMUM_LEVEL
    return newLevel
  end

  def self.getNewLevelToTrainer(difficulty)
    higherLevel = getHigherPartyLevel
    balance = pbBalancedLevel($player.party)
    case difficulty
      when LIGHT
        debugMessage("Set difficulty LIGHT\n")
        return balance / 2 - 2 + rand(5)
      when EASY
        debugMessage("Set difficulty EASY\n")
        return 2 * balance / 4  - 4 + rand(8)
      when MEDIUM
        debugMessage("Set difficulty MEDIUM\n")
        return 3 * (balance + 4 * higherLevel) / 50 - 4 + rand(4 + balance / 10)
      when HARD
        debugMessage("Set difficulty HARD\n")
        return 4 * (balance + 4 * higherLevel) / 50 - 4 + rand(4 + balance / 10)
      when INSANE
        debugMessage("Set difficulty INSANE\n")
        return (balance + 4 * higherLevel) / 20 - 4 + rand(4 + balance / 10)
      else #EXTREME
        debugMessage("Set difficulty EXTREME\n")
        return 9 * (balance + 4 * higherLevel) / 25 - 4 + rand(4 + balance / 10)
    end
  end

  def self.getNewLevelToWild(difficulty)
    higherLevel = getHigherPartyLevel
    balance = pbBalancedLevel($player.party)
    case difficulty
      when LIGHT
        debugMessage("Set difficulty LIGHT\n")
        return balance / 3 - 2 + rand(5)
      when EASY
        debugMessage("Set difficulty EASY\n")
        return 2 * balance / 3  - 4 + rand(8)
      when MEDIUM
        debugMessage("Set difficulty MEDIUM\n")
        return 3 * (balance + 4 * higherLevel) / 20 - 4 + rand(8)
      when HARD
        debugMessage("Set difficulty HARD\n")
        return 4 * (balance + 4 * higherLevel) / 25 - 2 + rand(8)
      when INSANE
        debugMessage("Set difficulty INSANE\n")
        return (balance + 4 * higherLevel) / 6 - 4 + rand(4 + balance / 10)
      else #EXTREME
        debugMessage("Set difficulty EXTREME\n")
        return 9 * (balance + 4 * higherLevel) / 50 - 4 + rand(4 + balance / 10)
    end
  end

  def self.debugMessage(message)
    if DEBUG_MODE
      echoln message 
    end
  end

  def self.getSpecies(specieId)
    return GameData::Species.get(specieId)
  end
  
end