//import { ChainId, Token, TokenAmount, Pair, Trade, TradeType, Route } from '@uniswap/sdk'
import Web3 from 'web3'
import { newKitFromWeb3 } from '@celo/contractkit'
import BigNumber from "bignumber.js"
import NetworksAbi from '../contract/Networks.abi.json'
import erc20Abi from "../contract/erc20.abi.json"

const ERC20_DECIMALS = 18
const APaddress = "0xbf2Ac58D115f2458E67c205699Ec461BC12b75A6"
const cUSDContractAddress = "0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1"

let kit
let contract
let Listings

const _Listings =[]

const connectCeloWallet = async function () {
  if (window.celo) {
      notification("⚠️ Please approve this DApp to use it.")
    try {
      await window.celo.enable()
      notificationOff()

      const web3 = new Web3(window.celo)
      kit = newKitFromWeb3(web3)

      const accounts = await kit.web3.eth.getAccounts()
      kit.defaultAccount = accounts[0]
      contract = new kit.web3.eth.Contract(NetworksAbi, APaddress)

    } catch (error) {
      notification(`⚠️ ${error}.`)
    }
  } else {
    notification("⚠️ Please install the CeloExtensionWallet.")
  }
}

async function approve(_price) {
  const cUSDContract = new kit.web3.eth.Contract(erc20Abi, cUSDContractAddress)

  const result = await cUSDContract.methods
    .approve(APaddress, _price)
    .send({ from: kit.defaultAccount })
  return result
}

const getBalance = async function () {
    const totalBalance = await kit.getTotalBalance(kit.defaultAccount)
    const cUSDBalance = totalBalance.cUSD.shiftedBy(-ERC20_DECIMALS).toFixed(2)
    document.querySelector("#balance").textContent = cUSDBalance
}

const getListings = async function() {
  const _listingSize = await contract.methods.gettotallistings().call()

  for(let i =0; i < _listingSize; i++){
    let _data = new Promise(async (resolve,reject) =>{
      let p =await contract.methods.getListing(i).call()
      resolve({
        index: i,
        owner: p[0],
        name:p[1],
        image:p[2],
        price : p[3],
        NOU: p[4],
      })
    })
    _Listings.push(_data)
  }

  Listings = await Promise.all(_Listings)
  renderListings()
}

function renderListings() {
    document.getElementById("DataMarket").innerHTML = ""
    Listings.forEach((_listing) => {
      const newDiv = document.createElement("div")
      newDiv.className = "col-md-4"
      newDiv.innerHTML = ListingsTemplate(_listing)
      document.getElementById("DataMarket").appendChild(newDiv)
    })
}


function  ListingsTemplate(_listing) {
  return `
    <div class="card mb-4">
      <img class="card-img-top" src="${_listing.image}" alt="...">
      </div>
      <div class="card-body text-left p-4 position-relative">
      <div class="translate-middle-y position-absolute top-0">
      ${identiconTemplate(_listing.owner)}
      </div>
      <h2 class="card-title fs-4 fw-bold mt-2">${_listing.name}</h2>
      <p class="card-text mb-4" style="min-height: 82px">
        ${_listing.description}             
      </p>
      <p class="card-text mt-4">
        <i class="bi bi-geo-alt-fill"></i>
        <span> Units Available ${_listing.NOU}</span>
      </p>
      <a class="btn btn-lg btn-outline-dark BuyBtn fs-6 p-3" id=${
        _listing.index}
      >
        Buy Data
      </a><a class="btn btn-lg btn-outline-dark UseBtn fs-6 p-3" id=${
        _listing.index}
      >
        Use Data
      </a>
      <a class="btn btn-lg btn-outline-dark DeleteBtn fs-6 p-3" id=${
        _listing.index}
      >
        Delete Data
      </a>
    </div>
  </div>
`
}  

function identiconTemplate(_address) {
  const icon = blockies
    .create({
      seed: _address,
      size: 8,
      scale: 16,
    })
    .toDataURL()

  return `
  <div class="rounded-circle overflow-hidden d-inline-block border border-white border-2 shadow-sm m-0">
    <a href="https://alfajores-blockscout.celo-testnet.org/address/${_address}/transactions"
        target="_blank">
        <img src="${icon}" width="48" alt="${_address}">
    </a>
  </div>
  `
}

function notification(_text) {
  document.querySelector(".alert").style.display = "block"
  document.querySelector("#notification").textContent = _text
}

function notificationOff() {
  document.querySelector(".alert").style.display = "none"
}

window.addEventListener("load", async () => {
  notification("⌛ Loading...")
  await connectCeloWallet()
  getBalance()
  notificationOff()
  getListings()
  
})


  
  document
  .querySelector("#newDataBtn")
  .addEventListener("click", async () => {
    const params = [
      document.getElementById("newDataSetName").value,
      document.getElementById("newDataDescription").value,
      document.getElementById("newDataImage").value,
      new BigNumber(document.getElementById("newDataPrice").value)
      .shiftedBy(ERC20_DECIMALS)
      .toString(),
    ]
    
    try {
      const result = await contract.methods
        .createListing(...params)
        .send({ from: kit.defaultAccount })
    } catch (error) {
      notification(`⚠️ ${error}.`)
    }
    notification(`🎉 You successfully added "${params[0]}".`)
    getListings()
  })

  
  document.querySelector("#ListingsRender")
  .addEventListener("click", async () => {
    getListings()
  })

  document.querySelector("#DataMarket").addEventListener("click", async (e) => {
    if(e.target.className.includes("DeleteBtn")) {
      const index = e.target.id
      
      if (_Listings[index].title != ""){
        
        try {
        await approve(new BigNumber(_Listings[index].price))
        const result = await contract.methods
          .removeListing(index)
          .send({ from: kit.defaultAccount })
          notification(`🎉 You successfully Delisted "${_Listings[index]}".`)
          getListings()
          getBalance()
          } catch (error) {
            notification(`⚠️ ${error}.`)
          }
      }
      
    }

  })

  
  document.querySelector("#DataMarket").addEventListener("click", async (e) => {
    if(e.target.className.includes("BuyBtn")) {
      const index = e.target.id
    
    try {
      await approve((_Listings[index].price))
      const result = await contract.methods
        .purchaseListings(index)
        .send({ from: kit.defaultAccount })
    } catch (error) {
      notification(`⚠️ ${error}.`)
    }
    notification(`🎉 You successfully bought "${params[1]}" units of"${_Listings[params[0]].name}".`)
    getListings()
  }
  })


  document.querySelector("#DataMarket").addEventListener("click", async (e) => {
    if(e.target.className.includes("UseBtn")) {
      const index = e.target.id
    
    try {
      const result = await contract.methods
        .getListingForUse(index)
        .send({ from: kit.defaultAccount })
    } catch (error) {
      notification(`⚠️ ${error}.`)
    }
    notification(`🎉 You successfully added Stock to "${_Listings[params[0]].name}".`)
    getListings()
  }
  })
