@storage_var
func pet_data(owner: felt) -> (hunger: felt, happiness: felt, energy: felt):
end

@view
func get_pet(owner: felt) -> (hunger: felt, happiness: felt, energy: felt, exists: felt):
    let (hunger, happiness, energy) = pet_data.read(owner)
    let exists = 1 if hunger != 0 or happiness != 0 or energy != 0 else 0
    return (hunger, happiness, energy, exists)

@external
func create_pet(owner: felt):
    let (hunger, happiness, energy) = pet_data.read(owner)
    assert hunger == 0 and happiness == 0 and energy == 0, 'Pet already exists'

    let initial_hunger = 50
    let initial_happiness = 50
    let initial_energy = 50
    pet_data.write(owner, (initial_hunger, initial_happiness, initial_energy))
    return ()

@external
func interact(owner: felt, action: felt):
    let (hunger, happiness, energy) = pet_data.read(owner)
    assert hunger != 0 or happiness != 0 or energy != 0, 'Pet does not exist'

    let new_hunger = hunger
    let new_happiness = happiness
    let new_energy = energy

    if action == 1: // Feed
        new_hunger = max(0, hunger - 10)
    elseif action == 2: // Play
        new_happiness = min(100, happiness + 10)
        new_energy = max(0, energy - 10)
    elseif action == 3: // Rest
        new_energy = min(100, energy + 20)
    end

    pet_data.write(owner, (new_hunger, new_happiness, new_energy))
    return ()
