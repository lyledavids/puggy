<!-- <script>
    import { onMount } from 'svelte';
    import { getStarknet } from 'get-starknet';
  
    let pet = { hunger: 0, happiness: 0, energy: 0 };
    let mood = '';
    let starknet;
    let connectedAccount = '';
    let petExists = false;
  
    const connectWallet = async () => {
      try {
        starknet = getStarknet();
        await starknet.enable({ showModal: true });
        connectedAccount = starknet.selectedAddress;
  
        if (connectedAccount) {
          checkPet();
        }
      } catch (error) {
        console.error('Error connecting wallet:', error);
      }
    };
  
    const createPet = async () => {
      try {
        await fetch(`http://localhost:3000/pet/${connectedAccount}/create`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' }
        });
        checkPet();
      } catch (error) {
        console.error('Error creating pet:', error);
      }
    };
  
    const checkPet = async () => {
      try {
        const response = await fetch(`http://localhost:3000/pet/${connectedAccount}`);
        if (response.status === 404) {
          petExists = false;
        } else {
          const data = await response.json();
          pet = data;
          petExists = true;
          fetchMood();
        }
      } catch (error) {
        console.error('Error checking pet:', error);
      }
    };
  
    const fetchMood = () => {
      const moods = ['Happy', 'Neutral', 'Sad'];
      mood = moods[pet.mood];
    };
  
    const interactWithPet = async (action) => {
      if (!petExists) return;
      try {
        await fetch(`http://localhost:3000/pet/${connectedAccount}/interact`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ action })
        });
        checkPet();
      } catch (error) {
        console.error('Error interacting with pet:', error);
      }
    };
  
    onMount(() => {
      connectWallet();
    });
  </script>
  
  <div class="container mx-auto p-6">
    <h1 class="text-2xl font-bold mb-4">Puggy</h1>
  
    {#if connectedAccount}
      <p>Connected Wallet: {connectedAccount}</p>
      
      {#if petExists}
        <div class="bg-white p-4 rounded shadow">
          <p>Hunger: {pet.hunger}</p>
          <p>Happiness: {pet.happiness}</p>
          <p>Energy: {pet.energy}</p>
          <p>Mood: {mood}</p>
          <div class="mt-4">
            <button on:click={() => interactWithPet(1)} class="btn">Feed</button>
            <button on:click={() => interactWithPet(2)} class="btn ml-2">Play</button>
            <button on:click={() => interactWithPet(3)} class="btn ml-2">Rest</button>
          </div>
        </div>
      {:else}
        <p>No pet found. Create one now!</p>
        <button on:click={createPet} class="btn">Create Pet</button>
      {/if}
    {:else}
      <button on:click={connectWallet} class="btn">Connect Wallet</button>
    {/if}
  </div>
   -->

   <script>
    let connectedAccount = null;
    let pet = { hunger: 50, happiness: 50, energy: 50 };
    let mood = 'neutral';
  
    function connectWallet() {
      connectedAccount = '0x1234...5678';
    }
  
    function disconnectWallet() {
      connectedAccount = null;
    }
  
    function interactWithPet(action) {
      if (!connectedAccount) {
        alert('Please connect your wallet first!');
        return;
      }
      console.log(`Interacting with pet: ${action}`);
      if (action === 'feed') pet.hunger = Math.min(100, pet.hunger + 10);
      if (action === 'play') pet.happiness = Math.min(100, pet.happiness + 10);
      if (action === 'rest') pet.energy = Math.min(100, pet.energy + 10);
      pet = pet; // Trigger reactivity
    }
  
    $: {
      const average = (pet.hunger + pet.happiness + pet.energy) / 3;
      if (average > 80) mood = 'happy';
      else if (average > 50) mood = 'neutral';
      else if (average > 30) mood = 'sad';
      else mood = 'angry';
    }
  </script>
  
  <div class="container mx-auto p-6">
    <h1 class="text-2xl font-bold mb-4">Puggy</h1>
  
    <div class="bg-white p-4 rounded shadow">
      <div class="pug {mood}">
        <div class="body"></div>
        <div class="head">
          <div class="ears">
            <div class="ear"></div>
            <div class="ear"></div>
          </div>
          <div class="face">
            <div class="eyes">
              <div class="eye"><div class="pupil"></div></div>
              <div class="eye"><div class="pupil"></div></div>
            </div>
            <div class="muzzle">
              <div class="nose"></div>
              <div class="mouth"></div>
            </div>
          </div>
        </div>
        <div class="legs">
          <div class="leg front-left"></div>
          <div class="leg front-right"></div>
          <div class="leg back-left"></div>
          <div class="leg back-right"></div>
        </div>
        <div class="tail"></div>
      </div>
      <div class="mt-4 flex justify-between">
        <p>Hunger: {pet.hunger}</p>
        <p>Happiness: {pet.happiness}</p>
        <p>Energy: {pet.energy}</p>
      </div>
      <div class="mt-4">
        <button on:click={() => interactWithPet('feed')} class="btn">Feed</button>
        <button on:click={() => interactWithPet('play')} class="btn ml-2">Play</button>
        <button on:click={() => interactWithPet('rest')} class="btn ml-2">Rest</button>
      </div>
    </div>
  
    {#if connectedAccount}
      <div class="mt-4">
        <p>Connected Wallet: {connectedAccount}</p>
        <button on:click={disconnectWallet} class="btn mt-2">Disconnect Wallet</button>
      </div>
    {:else}
      <div class="mt-4">
        <button on:click={connectWallet} class="btn">Connect Wallet</button>
      </div>
    {/if}
  </div>
  
  <style>
    .pug {
      width: 200px;
      height: 240px;
      position: relative;
      margin: 50px auto;
    }
  
    .body {
      width: 140px;
      height: 90px;
      background-color: #D2B48C;
      border-radius: 50% 50% 0 0;
      position: absolute;
      bottom: 30px;
      left: 30px;
    }
  
    .head {
      width: 120px;
      height: 120px;
      background-color: #D2B48C;
      border-radius: 50%;
      position: absolute;
      top: 0;
      left: 40px;
    }
  
    .ears {
      position: absolute;
      top: -10px;
      width: 100%;
    }
  
    .ear {
      width: 40px;
      height: 40px;
      background-color: #8B4513;
      border-radius: 50%;
      position: absolute;
    }
  
    .ear:first-child {
      left: 5px;
    }
  
    .ear:last-child {
      right: 5px;
    }
  
    .face {
      position: absolute;
      width: 100px;
      height: 100px;
      background-color: #8B4513;
      border-radius: 50%;
      top: 10px;
      left: 10px;
    }
  
    .eyes {
      display: flex;
      justify-content: space-around;
      padding-top: 20px;
    }
  
    .eye {
      width: 25px;
      height: 25px;
      background-color: white;
      border-radius: 50%;
      position: relative;
      overflow: hidden;
    }
  
    .pupil {
      width: 12px;
      height: 12px;
      background-color: black;
      border-radius: 50%;
      position: absolute;
      top: 50%;
      left: 50%;
      transform: translate(-50%, -50%);
    }
  
    .muzzle {
      width: 60px;
      height: 60px;
      background-color: #D2B48C;
      border-radius: 50%;
      position: absolute;
      bottom: -5px;
      left: 50%;
      transform: translateX(-50%);
    }
  
    .nose {
      width: 16px;
      height: 8px;
      background-color: black;
      border-radius: 50%;
      position: absolute;
      top: 15px;
      left: 50%;
      transform: translateX(-50%);
    }
  
    .mouth {
      width: 30px;
      height: 15px;
      border-radius: 0 0 15px 15px;
      border: 2px solid black;
      border-top: none;
      position: absolute;
      bottom: 15px;
      left: 50%;
      transform: translateX(-50%);
    }
  
    .legs {
      position: absolute;
      bottom: 0;
      width: 100%;
    }
  
    .leg {
      width: 20px;
      height: 30px;
      background-color: #8B4513;
      position: absolute;
      bottom: 0;
    }
  
    .leg.front-left { left: 30px; }
    .leg.front-right { left: 60px; }
    .leg.back-left { right: 60px; }
    .leg.back-right { right: 30px; }
  
    .tail {
      width: 20px;
      height: 40px;
      background-color: #8B4513;
      position: absolute;
      bottom: 30px;
      right: 20px;
      border-radius: 0 0 50% 50%;
      transform: rotate(30deg);
    }
  
    .happy .mouth {
      border-radius: 15px 15px 0 0;
      border: 2px solid black;
      border-bottom: none;
      bottom: 20px;
    }
  
    .sad .mouth {
      transform: translateX(-50%) rotate(180deg);
      bottom: 10px;
    }
  
    .angry .eyes::before,
    .angry .eyes::after {
      content: '';
      position: absolute;
      width: 30px;
      height: 5px;
      background-color: #8B4513;
      top: 15px;
    }
  
    .angry .eyes::before {
      left: 15px;
      transform: rotate(30deg);
    }
  
    .angry .eyes::after {
      right: 15px;
      transform: rotate(-30deg);
    }
  
    .btn {
      @apply bg-blue-500 text-white font-bold py-2 px-4 rounded;
    }
  
    .btn:hover {
      @apply bg-blue-700;
    }
  </style>