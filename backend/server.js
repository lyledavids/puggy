const express = require('express');
const { exec } = require('child_process');
const { Provider, Contract } = require('starknet');

const app = express();
const provider = new Provider({ network: 'testnet' });
const contractAddress = ''; 
const abi = require('./contract/abi.json'); // ABI 
const contract = new Contract(abi, contractAddress, provider);

app.use(express.json());

// Endpoint to fetch pet data
app.get('/pet/:owner', async (req, res) => {
  try {
    const { owner } = req.params;
    const petData = await contract.get_pet(owner).call();
    const { hunger, happiness, energy, exists } = petData;

    if (exists === 0) {
      return res.status(404).json({ error: 'Pet does not exist' });
    }

    // Run the Python script to predict the mood
    exec(`python3 ai/mood_model.py ${hunger} ${happiness} ${energy}`, (error, stdout, stderr) => {
      if (error) {
        console.error(`Error executing Python script: ${stderr}`);
        return res.status(500).json({ error: 'Error predicting pet mood' });
      }

      const mood = parseInt(stdout.trim(), 10);
      res.json({
        hunger,
        happiness,
        energy,
        mood, 
      });
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error fetching pet data' });
  }
});

// Endpoint to create a new pet
app.post('/pet/create', async (req, res) => {
  const { owner } = req.body;
  
  try {
    const tx = await contract.create_pet(owner).invoke();
    await tx.wait();
    res.status(201).json({ message: 'Pet created successfully', transactionId: tx.transaction_hash });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error creating pet' });
  }
});

// Endpoint to interact with the pet (feed, play, rest)
app.post('/pet/:owner/interact', async (req, res) => {
  const { owner } = req.params;
  const { action } = req.body; // action will be 1, 2, or 3

  try {
    const tx = await contract.interact(owner, action).invoke();
    await tx.wait();
    res.json({ message: 'Pet interacted with successfully', transactionId: tx.transaction_hash });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error interacting with pet' });
  }
});

// Starting the server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
