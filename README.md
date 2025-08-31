# FundMe Smart Contract

Một smart contract gây quỹ phi tập trung được xây dựng trên Ethereum cho phép người dùng đóng góp ETH vào các dự án và cho phép chủ sở hữu dự án rút tiền đã thu được. Contract sử dụng Chainlink price feeds để thiết lập số tiền đóng góp tối thiểu theo USD.

## 🌟 Tính năng

- **Số tiền tối thiểu theo USD**: Áp dụng số tiền đóng góp tối thiểu $5 USD sử dụng Chainlink price feeds
- **Chỉ chủ sở hữu mới có thể rút tiền**: Chỉ có chủ sở hữu contract mới có thể rút quỹ đã thu được
- **Tối ưu Gas**: Sử dụng biến `constant`, `immutable` và custom errors để tối ưu gas
- **Theo dõi người đóng góp**: Lưu trữ hồ sơ của tất cả người đóng góp và số tiền của họ
- **Hỗ trợ ETH trực tiếp**: Chấp nhận chuyển ETH trực tiếp qua `receive()` và `fallback()` functions
- **Event Logging**: Phát ra events để đảm bảo minh bạch và theo dõi off-chain

## 📋 Chi tiết Contract

### Mạng đã Deploy

| Mạng | Địa chỉ Contract | Price Feed |
|------|------------------|------------|
| Sepolia Testnet | `0xf5D1887381E927Fd908B3064847931E042710154` | ETH/USD |
| ZKsync Sepolia | *Sắp có* | ETH/USD |

### Hằng số chính

- **Số tiền đóng góp tối thiểu**: $5 USD (tương đương ETH)
- **Phiên bản Solidity**: ^0.8.24
- **Giấy phép**: MIT

## 🚀 Bắt đầu nhanh

### Yêu cầu

- Ví MetaMask
- Sepolia testnet ETH ([Lấy từ faucet](https://sepoliafaucet.com/))
- Hiểu biết cơ bản về giao dịch Ethereum

### Tương tác với Contract

#### 1. Đóng góp cho dự án

Gửi ETH đến contract (tối thiểu tương đương $5 USD):

```javascript
// Qua function của contract
await fundMe.fund({ value: ethers.utils.parseEther("0.01") })

// Qua chuyển khoản trực tiếp (kích hoạt receive function)
await wallet.sendTransaction({
    to: "0xf5D1887381E927Fd908B3064847931E042710154",
    value: ethers.utils.parseEther("0.01")
})
```

#### 2. Kiểm tra số dư Contract

```javascript
const balance = await fundMe.getBalance()
console.log(`Số dư contract: ${ethers.utils.formatEther(balance)} ETH`)
```

#### 3. Xem số tiền bạn đã đóng góp

```javascript
const myContribution = await fundMe.getFundingAmount(yourAddress)
console.log(`Bạn đã đóng góp: ${ethers.utils.formatEther(myContribution)} ETH`)
```

## 🔧 Các Function của Contract

### Functions công khai

| Function | Mô tả | Quyền truy cập |
|----------|-------|----------------|
| `fund()` | Đóng góp ETH cho dự án | Mọi người |
| `getBalance()` | Lấy số dư hiện tại của contract | Mọi người |
| `getPrice()` | Lấy giá ETH/USD hiện tại | Mọi người |
| `getConversionRate(uint256)` | Chuyển đổi ETH sang USD | Mọi người |
| `getFunder(uint256)` | Lấy người đóng góp theo chỉ số | Mọi người |
| `getFundingAmount(address)` | Lấy số tiền đóng góp theo địa chỉ | Mọi người |
| `getNumberOfFunders()` | Lấy tổng số người đóng góp | Mọi người |

### Functions chỉ dành cho Owner

| Function | Mô tả |
|----------|-------|
| `withdraw()` | Rút tất cả tiền và reset dữ liệu người đóng góp |
| `cheaperWithdraw()` | Phiên bản tối ưu gas của withdraw |

### Functions đặc biệt

| Function | Kích hoạt | Mục đích |
|----------|-----------|----------|
| `receive()` | Chuyển ETH trực tiếp (không có data) | Tự động đóng góp |
| `fallback()` | Chuyển ETH có kèm data | Tự động đóng góp |

## 💰 Ví dụ về đóng góp

### Tính toán số tiền đóng góp tối thiểu

Contract yêu cầu tối thiểu $5 USD. Dưới đây là một số ví dụ:

```solidity
// Nếu giá ETH = $2000
// ETH tối thiểu cần = $5 / $2000 = 0.0025 ETH

// Nếu giá ETH = $3000
// ETH tối thiểu cần = $5 / $3000 = 0.00167 ETH
```

### Đóng góp qua Web3

```javascript
// Sử dụng ethers.js
const provider = new ethers.providers.Web3Provider(window.ethereum)
const signer = provider.getSigner()
const fundMe = new ethers.Contract(contractAddress, abi, signer)

// Đóng góp 0.01 ETH
const tx = await fundMe.fund({ 
    value: ethers.utils.parseEther("0.01") 
})
await tx.wait()

console.log("Đóng góp thành công!")
```

### Đóng góp qua chuyển khoản trực tiếp

```javascript
// Gửi ETH trực tiếp đến địa chỉ contract
const tx = await signer.sendTransaction({
    to: "0xf5D1887381E927Fd908B3064847931E042710154",
    value: ethers.utils.parseEther("0.01")
})
```

## 🔍 Xác minh Contract

Contract đã được xác minh trên Etherscan. Bạn có thể:

1. **Xem mã nguồn**: [Link Etherscan](https://sepolia.etherscan.io/address/0xf5D1887381E927Fd908B3064847931E042710154)
2. **Read Contract**: Kiểm tra tất cả biến và function công khai
3. **Write Contract**: Tương tác trực tiếp qua giao diện Etherscan

## 📊 Events

Contract phát ra các events sau:

```solidity
event FundingReceived(address indexed funder, uint256 amount);
event FundsWithdrawn(address indexed owner, uint256 amount);
```

### Theo dõi Events

```javascript
// Lắng nghe events đóng góp
fundMe.on("FundingReceived", (funder, amount, event) => {
    console.log(`${funder} đã đóng góp ${ethers.utils.formatEther(amount)} ETH`)
})

// Lắng nghe events rút tiền
fundMe.on("FundsWithdrawn", (owner, amount, event) => {
    console.log(`Owner đã rút ${ethers.utils.formatEther(amount)} ETH`)
})
```

## 🛡️ Tính năng bảo mật

### Kiểm soát truy cập
- **Chỉ owner mới rút được tiền**: Chỉ người deploy contract mới có thể rút tiền
- **Custom errors**: Xử lý lỗi hiệu quả về gas
- **Chuyển khoản an toàn**: Sử dụng `call` mức thấp để chuyển ETH an toàn

### Bảo mật Price Feed
- **Tích hợp Chainlink**: Dữ liệu giá đáng tin cậy, phi tập trung
- **Chuyển đổi USD tự động**: Minimum động dựa trên giá ETH hiện tại
- **Xác minh price feed**: Đảm bảo tính toàn vẹn dữ liệu giá

## 📈 Tối ưu Gas

Contract triển khai nhiều kỹ thuật tiết kiệm gas:

| Tối ưu hóa | Gas tiết kiệm | Triển khai |
|------------|---------------|------------|
| Custom Errors | ~90% | `revert NotOwner()` vs `require()` |
| Immutable Variables | ~17,000 | `immutable i_owner` |
| Constant Variables | ~20,000 | `constant MINIMUM_USD` |
| Memory Arrays | ~2,000/vòng lặp | Function `cheaperWithdraw()` |

## 🧪 Kiểm thử

### Danh sách kiểm thử thủ công

- [ ] Đóng góp với số tiền < $5 USD (phải thất bại)
- [ ] Đóng góp với số tiền ≥ $5 USD (phải thành công)
- [ ] Chuyển ETH trực tiếp đến contract (phải kích hoạt `fund()`)
- [ ] Thử rút tiền khi không phải owner (phải thất bại)
- [ ] Owner rút tiền (phải thành công và reset funders)
- [ ] Kiểm tra độ chính xác theo dõi funder
- [ ] Xác minh event emissions

### Thông tin Test Network

```
Mạng: Sepolia Testnet
Chain ID: 11155111
RPC URL: https://sepolia.infura.io/v3/YOUR_KEY
Block Explorer: https://sepolia.etherscan.io/
```

## 🔗 Tài nguyên liên quan

- **Chainlink Price Feeds**: [Tài liệu](https://docs.chain.link/data-feeds)
- **Sepolia Faucet**: [Lấy Test ETH](https://sepoliafaucet.com/)
- **Etherscan**: [Contract Explorer](https://sepolia.etherscan.io/)
- **Remix IDE**: [Solidity IDE Online](https://remix.ethereum.org/)

## 📄 Contract ABI

<details>
<summary>Nhấn để xem ABI</summary>

```json
[
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "priceFeedAddress",
        "type": "address"
      }
    ],
    "stateMutability": "nonpayable",
    "type": "constructor"
  },
  {
    "inputs": [],
    "name": "InsufficientFunding",
    "type": "error"
  },
  {
    "inputs": [],
    "name": "NotOwner",
    "type": "error"
  },
  {
    "inputs": [],
    "name": "TransferFailed",
    "type": "error"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": true,
        "internalType": "address",
        "name": "funder",
        "type": "address"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "amount",
        "type": "uint256"
      }
    ],
    "name": "FundingReceived",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": true,
        "internalType": "address",
        "name": "owner",
        "type": "address"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "amount",
        "type": "uint256"
      }
    ],
    "name": "FundsWithdrawn",
    "type": "event"
  },
  {
    "stateMutability": "payable",
    "type": "fallback"
  },
  {
    "inputs": [],
    "name": "fund",
    "outputs": [],
    "stateMutability": "payable",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "getBalance",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "uint256",
        "name": "ethAmount",
        "type": "uint256"
      }
    ],
    "name": "getConversionRate",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "uint256",
        "name": "index",
        "type": "uint256"
      }
    ],
    "name": "getFunder",
    "outputs": [
      {
        "internalType": "address",
        "name": "",
        "type": "address"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "funder",
        "type": "address"
      }
    ],
    "name": "getFundingAmount",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "getNumberOfFunders",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "getOwner",
    "outputs": [
      {
        "internalType": "address",
        "name": "",
        "type": "address"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "getPrice",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "withdraw",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "stateMutability": "payable",
    "type": "receive"
  }
]
```

</details>

## 🤝 Đóng góp

Đây là một dự án giáo dục để học Solidity và phát triển smart contract. Hãy thoải mái:

- Báo cáo bugs hoặc issues
- Đề xuất cải tiến
- Fork và thử nghiệm
- Chia sẻ trải nghiệm học tập của bạn

## 📝 Giấy phép

Dự án này được cấp phép theo MIT License - xem mã nguồn contract để biết chi tiết.

## ⚠️ Tuyên bố miễn trừ trách nhiệm

Contract này được deploy trên **Sepolia testnet** chỉ cho mục đích giáo dục. Không gửi ETH mainnet thật đến contract này. Luôn xác minh địa chỉ contract và test trên testnet trước khi sử dụng tiền thật.

---

**Chúc học tập vui vẻ! 🎓**

Nếu có thắc mắc hoặc cần hỗ trợ, hãy liên hệ hoặc kiểm tra contract trên [Sepolia Etherscan](https://sepolia.etherscan.io/address/0xf5D1887381E927Fd908B3064847931E042710154).