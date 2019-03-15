pragma solidity ^0.4.9;
// pragma solidity ^0.5.2;
// pragma experimental ABIEncoderV2;

import "../batteryaccesscontrol/BatteryUserRole.sol";

//------------------------------------------------------------------------------
// Decentralized EMS platform using Smart Contract for Warranty Application for 
//  - Battery Provider
//  - Battery Owner
//  - EMS Provider
//------------------------------------------------------------------------------
// Contract to manage Smart Warranty regarding  
//  - Annual average SOC condition
//  - Average hourly temperature condition
//  - Annual accumulated discharge energy of the product
//  - Peak DC power per rack
//  - Daily average rack power
//  - Substantial portion of all half-cycles
//------------------------------------------------------------------------------
contract SupplyChain {
    
    // Battery and Warranty Provider (e.g. LG Chem)
    address batteryProvider;
    
    // Energy Management System (EMS) Provider (e.g. NEC Energy Solution)
    address trustedEMSProvider;
    
    // Variable: tokenId for a battery that is used to distinguish all the batteries produced by the provider
    uint public tokenId = 1;

    // List of warranty parameters
    uint max_average_soc;
    uint peak_dc_rack_power;
    uint daily_avg_rack_power;

    // uint abs_min_enclosure_temp;
    // uint nom_min_enclosure_temp;
    // uint max_enclosure_temp;
    // uint min_module_temp;
    // uint max_average_enclosure_temp;
    // uint abs_max_storage_temp;
    // uint max_module_oper_temp;
    // uint soc_penalty_factor;
    // uint avg_temp_penalty_factor_1;
    // uint avg_temp_penalty_factor_2;
    // uint avg_temp_penalty_factor_3;
    // uint peak_power_penalty_factor;
    // uint avg_power_penalty_factor;
    // uint max_dod;
    
    // Need to add DEFAULT
    enum State {DEFAULT, PRODUCED, FORSALE, SOLD, INSTALLED, MANAGED, ACTIVE, RETURNED}
    enum WarrantyStatus {UNDER_WARRANTY, OUT_OF_WARRANTY}

    // Owner's Information
    struct OwnerInfo {
        string ownerID;
        string firstName;
        string lastName;
        string companyName;
    }
    
    // EMS Provider information: need to be approved by the battery provider
    struct EnergyManagementSystemProvider {
        address emsProvider;
        bool isApproved;
    }
    
    // Battery Information
    struct BatteryInfo {
        
        // An arbitrary battery ID
        string batteryID;
        
        // The onwer of the battery after sold
        address owner;
        
        // Trusted EMS Provider (e.g. NEC)
        address emsProvider;
        
        // Original Capacity in kWh
        uint bolCapacity;
        
        // Maximum power (PCS) in kW
        uint maxPower;
        
        // Battery price in Ether
        uint price;
        
        // Degraded capacity
        // If it reaches 60%, the battery is goint to be out of warranty
        uint adjustedCapacity;
        
        uint annual_accum_disch_energy;
        
        // State: forSale, sold, managed, underControl, returned, etc.
        State state;
        
        // WarrantyStatus: underWarranty or outOfWarranty
        WarrantyStatus warrantyStatus;
        
        // Current year
        uint currentYear;
        
        // Warranty period could be 3 years or 4-10 years with extension as long as 60% of the capacity remains
        // If you want to extend, you have to pay for extension before the year
        uint warrantyPeriod; 
        // uint extendedWarranty;
    
        // uint acceptedDate;
        // uint operationStartDateTime;
        // uint operationEndDateTime;
        // uint warrantyViolatedDateTime;
        
        // In reality, this becomes much more complicated with the real-time Application, this is beta version of warranty app
        // Later it is going to be updated to accomodate multi-year data
        bool isDataReported;
        AnnualAverageSOC annualAverageSOC;
        AnnualAccumulatedDischargeEnergy aade;
        PeakDCPower peakDCPower;
        DailyAverageDCPower dailyAverageDCPower;
        
        // When the warranty contract should be expanded for multiple years
        //mapping(uint => AnnualAverageSOC) yearToAnnualAverageSOCInfo;
        //AnnualAverageSOC[] annualAverageSOCList;
        
        bool isWarrantyAnalyzed;
        WarrantyAnalysisInfo warrantyAnalysisInfo;
        
    }
    
    // Annual average SOC information
    struct AnnualAverageSOC {
        uint year;
        // uint startDate;
        // uint endDate;
        uint value;
        bool violationFlag;
    }
    
    // Annual Accumulated Discharge Energy Information
    struct AnnualAccumulatedDischargeEnergy {
        uint year;
        uint value;
        bool violationFlag;
    }
    
    // Peak DC Power Information
    struct PeakDCPower {
        uint year;
        uint month;
        uint day;
        uint hour;
        uint value;
        bool violationFlag;
    }
    
    // Daily Average DC Power Information
    struct DailyAverageDCPower {
        uint year;
        uint month;
        uint day;
        uint value;
        bool violationFlag;
    }

    // Warranty Violation Information for each conditioin
    // If one of following gets violated and becomes true, the warranty is out.
    struct WarrantyAnalysisInfo {
        bool annualAverageSOCViolation;
        bool annualAccumulatedDischargeEnergyViolation;
        bool peakDCPowerViolation;
        bool dailyAverageDCPowerViolation;
        //bool averageHourlyTemperatureViolation;
    }
    
    //mapping(address => OwnerInfo) addressToOwnerInfo;
    
    mapping(uint256 => BatteryInfo) tokenIdToBatteryInfo;
    //BatteryInfo[] public batteries; // Needed to deal with like an array
    
    // Events
    event ForSale(uint tokenId);
    event Sold(uint _tokenId);
    event Installed(uint _tokenId);
    event Managed(uint _tokenId);
    event Activated(uint _tokenId);
    
    // Currently the modifier conditions are minimized for easier testing
    modifier onlyProvider {
        require(msg.sender == batteryProvider);
        _;
    }
    
    modifier onlyEMSProvider(address _emsProvider) {
        require(msg.sender == _emsProvider);
        _;
    }
    
    modifier onlyOwner(address _owner) {
        require(msg.sender == _owner);
        _;
    }
    
    // Define a modifier that verifies the Caller
    modifier verifyCaller (address _address) {
        require(msg.sender == _address);
        _;
    }

    // Define a modifier that checks if the paid amount is sufficient to cover the price
    modifier paidEnough(uint _price) {
        require(msg.value >= _price);
        _;
    }

    // Define a modifier that checks if the state of the item of _tokenId is ForSale
    modifier forSale(uint _tokenId) {
        require(tokenIdToBatteryInfo[_tokenId].state == State.FORSALE);
        _;
    }

    // Define a modifier that checks if the state of the item of _tokenId is Sold
    modifier sold(uint _tokenId) {
        require(tokenIdToBatteryInfo[_tokenId].state == State.SOLD);
        _;
    }
    
    // Define a modifier that checks if the state of the item of _tokenId is Installed
    modifier installed(uint _tokenId) {
        require(tokenIdToBatteryInfo[_tokenId].state == State.INSTALLED);
        _;
    }
    
    // Define a modifier that checks if the state of the item of _tokenId is managed
    modifier managed(uint _tokenId) {
        require(tokenIdToBatteryInfo[_tokenId].state == State.MANAGED);
        _;
    }

    // Define a modifier that checks if the state of the item of _tokenId is activated
    modifier activated(uint _tokenId) {
        require(tokenIdToBatteryInfo[_tokenId].state == State.ACTIVE);
        _;
    }
    
    // Define a modifier that checks if the state of the item of _tokenId is activated
    modifier isDataReported(uint _tokenId) {
        require(tokenIdToBatteryInfo[_tokenId].isDataReported == true);
        _;
    }

    
    // Constructor: variables are all initialized here
    constructor() public {
        
        batteryProvider = msg.sender;
        
        max_average_soc = 53;
        peak_dc_rack_power = 45670;
        daily_avg_rack_power = 7600;
        // abs_min_enclosure_temp = 15;
        // nom_min_enclosure_temp = 18;
        // max_enclosure_temp = 28;
        // min_module_temp = 20;
        // max_average_enclosure_temp = 25;
        // abs_max_storage_temp = 60;
        // max_module_oper_temp = 26500;
        // annual_accum_disch_energy = 0;
        // soc_penalty_factor = 2300;
        // avg_temp_penalty_factor_1 = 4;
        // avg_temp_penalty_factor_2 = 10;
        // avg_temp_penalty_factor_3 = 80;
        // peak_power_penalty_factor = 1;
        // avg_power_penalty_factor = 9;
        //max_dod = 100;
        
    }
    
    function registerTrustedEMSProvider(address _address) public onlyProvider {
        trustedEMSProvider = _address;
    }
    
    // Registering battery information
    function registerBatteryInfo(string _batteryID, address batteryOwner, address trustedEMSProvider, uint capacity, uint power, uint year, uint warrantyPeriod) public onlyProvider {
        
        require(tokenId != 0);
        
        //BatteryInfo memory newBattery = BatteryInfo(_batteryID, batteryOwner, trustedEMSProvider, false, false, false, false, false);
        //tokenIdToBatteryInfo[tokenId] = newBattery;
        //tokenIdToBatteryInfo[tokenId].test[2013] = batteryOwner;
        
        tokenIdToBatteryInfo[tokenId].batteryID = _batteryID;
        tokenIdToBatteryInfo[tokenId].owner = batteryOwner;
        tokenIdToBatteryInfo[tokenId].emsProvider = trustedEMSProvider;
        tokenIdToBatteryInfo[tokenId].bolCapacity = capacity;
        tokenIdToBatteryInfo[tokenId].maxPower = power;
        tokenIdToBatteryInfo[tokenId].adjustedCapacity = capacity;
        tokenIdToBatteryInfo[tokenId].state = State.PRODUCED;
        tokenIdToBatteryInfo[tokenId].warrantyStatus = WarrantyStatus.UNDER_WARRANTY;
        tokenIdToBatteryInfo[tokenId].currentYear = year;
        tokenIdToBatteryInfo[tokenId].warrantyPeriod  = warrantyPeriod;

        tokenId ++;
    }

    
    // Registering battery information
    function produceBattery(string _batteryID, uint _capacity, uint _power, uint _price, uint _year, uint _warrantyPeriod) public onlyProvider {
        
        require(tokenId != 0);
        
        tokenIdToBatteryInfo[tokenId].batteryID = _batteryID;
        tokenIdToBatteryInfo[tokenId].bolCapacity = _capacity;
        tokenIdToBatteryInfo[tokenId].maxPower = _power;
        tokenIdToBatteryInfo[tokenId].price = _price;
        tokenIdToBatteryInfo[tokenId].adjustedCapacity = _capacity;
        // if year is leap year, need to be 366
        tokenIdToBatteryInfo[tokenId].annual_accum_disch_energy = 365 * 525 * _capacity;
        tokenIdToBatteryInfo[tokenId].state = State.PRODUCED;
        tokenIdToBatteryInfo[tokenId].warrantyStatus = WarrantyStatus.UNDER_WARRANTY;
        tokenIdToBatteryInfo[tokenId].currentYear = _year;
        tokenIdToBatteryInfo[tokenId].warrantyPeriod  = _warrantyPeriod;
        
        tokenId ++;
    }
    
    function addItem(uint _tokenId) public onlyProvider {
        require(tokenIdToBatteryInfo[_tokenId].state == State.PRODUCED);
        
        // Emit the appropriate event
        emit ForSale(_tokenId);
        
        tokenIdToBatteryInfo[_tokenId].state = State.FORSALE;
    }
    
    function buyItem(uint _tokenId) forSale(_tokenId) paidEnough(tokenIdToBatteryInfo[_tokenId].price) public payable {
        //require(tokenIdToBatteryInfo[tokenId].state == State.FORSALE);
        
        address buyer = msg.sender;
        uint price = tokenIdToBatteryInfo[_tokenId].price;

        // Update Buyer
        tokenIdToBatteryInfo[_tokenId].owner = buyer;

        // Update State
        tokenIdToBatteryInfo[_tokenId].state = State.SOLD;

        // Transfer money to seller
        batteryProvider.transfer(price);
        //items[sku].seller.transfer(price);

        // Emit the appropriate event
        emit Sold(_tokenId);
    }
    
    // Used only when the battery is transacted not using ether coins
    // In this case, this function is called only by battery provider after confirming the payment
    function assignBatteryOwner(uint _tokenId, address _address) forSale(_tokenId) onlyProvider public {

        // Update Buyer
        tokenIdToBatteryInfo[_tokenId].owner = _address;

        // Update State
        tokenIdToBatteryInfo[_tokenId].state = State.SOLD;

        // Emit the appropriate event
        emit Sold(_tokenId);
    }
    
    // Once the battery is sold, the onwner needs to install the battery
    function installBattery(uint _tokenId) sold(_tokenId) onlyOwner(tokenIdToBatteryInfo[_tokenId].owner) public {

        // Update State
        tokenIdToBatteryInfo[_tokenId].state = State.INSTALLED;
        
        // Emit the appropriate event
        emit Installed(_tokenId);
    }
    
    
    function manageBattery(uint _tokenId, address _emsProviderAddress) installed(_tokenId) onlyProvider public {
        
        // If needed, verify if _addrress is recorded as the trustedEMSProvider
        
        // Update EMS Provider
        tokenIdToBatteryInfo[_tokenId].emsProvider = _emsProviderAddress;
        
        // Update State
        tokenIdToBatteryInfo[_tokenId].state = State.MANAGED;

        // Emit the appropriate event
        emit Managed(_tokenId);
    }
    
    // EMS Provider should change the state of the battery to active when controling it
    function utilizeBattery(uint _tokenId) managed(_tokenId) onlyEMSProvider(tokenIdToBatteryInfo[_tokenId].emsProvider) public {
        
        // Update State
        tokenIdToBatteryInfo[_tokenId].state = State.ACTIVE;

        // Emit the appropriate event
        emit Activated(_tokenId);
    }
    
    // EMS Provider can record important information for warranty analysis
    function getUsageData(uint _tokenId, uint _year, uint _month, uint _day, uint _hour, uint _socValue, uint _aade, uint _peakDCPower, uint _averageDailyDCPower) activated(_tokenId) onlyEMSProvider(tokenIdToBatteryInfo[_tokenId].emsProvider) public {
        
        tokenIdToBatteryInfo[_tokenId].annualAverageSOC.year = _year;
        tokenIdToBatteryInfo[_tokenId].annualAverageSOC.value = _socValue;

        tokenIdToBatteryInfo[_tokenId].aade.year = _year;
        tokenIdToBatteryInfo[_tokenId].aade.value = _aade;

        tokenIdToBatteryInfo[_tokenId].peakDCPower.year = _year;
        tokenIdToBatteryInfo[_tokenId].peakDCPower.month = _month;
        tokenIdToBatteryInfo[_tokenId].peakDCPower.day = _day;
        tokenIdToBatteryInfo[_tokenId].peakDCPower.hour = _hour;
        tokenIdToBatteryInfo[_tokenId].peakDCPower.value = _peakDCPower;
        
        tokenIdToBatteryInfo[_tokenId].dailyAverageDCPower.year = _year;
        tokenIdToBatteryInfo[_tokenId].dailyAverageDCPower.month = _month;
        tokenIdToBatteryInfo[_tokenId].dailyAverageDCPower.day = _day;
        tokenIdToBatteryInfo[_tokenId].dailyAverageDCPower.value = _averageDailyDCPower;
        
        tokenIdToBatteryInfo[_tokenId].isDataReported = true;
    }
    
    // Once the warranty information is provided, the battery provider will check if the conditions are met
    function checkWarranty(uint _tokenId) activated(_tokenId) onlyProvider public {
        require(tokenIdToBatteryInfo[_tokenId].isDataReported == true);
        
        checkAnnualAverageSOCWarranty(_tokenId);
        checkAnnualAccumulatedDischargeEnergyWarranty(_tokenId);
        checkPeakDCPowerPerRackWarranty(_tokenId);
        checkDailyAverageDCPowerWarranty(_tokenId);
        
        tokenIdToBatteryInfo[_tokenId].isWarrantyAnalyzed = true;
    }
    
    // Checking Annual Average SOC Warranty
    function checkAnnualAverageSOCWarranty(uint _tokenId) activated(_tokenId) onlyProvider public {
        require(tokenIdToBatteryInfo[_tokenId].isDataReported == true);

        bool violationFlag = false;
        uint socValue = tokenIdToBatteryInfo[_tokenId].annualAverageSOC.value;

        if (socValue > max_average_soc) {
            tokenIdToBatteryInfo[_tokenId].annualAverageSOC.violationFlag = true;
            violationFlag = true;
        }
        
        tokenIdToBatteryInfo[_tokenId].warrantyAnalysisInfo.annualAverageSOCViolation = violationFlag;
    }
    
    // Checking Annual Accumulated Discharge Energy Warranty
    function checkAnnualAccumulatedDischargeEnergyWarranty(uint _tokenId) activated(_tokenId) onlyProvider public {

        require(tokenIdToBatteryInfo[_tokenId].isDataReported == true);
        
        bool violationFlag = false;
        uint aade = tokenIdToBatteryInfo[_tokenId].aade.value;
        if (aade > tokenIdToBatteryInfo[_tokenId].annual_accum_disch_energy) {
            tokenIdToBatteryInfo[_tokenId].aade.violationFlag = true;
            violationFlag = true;
        }
        
        tokenIdToBatteryInfo[_tokenId].warrantyAnalysisInfo.annualAccumulatedDischargeEnergyViolation = violationFlag;
    }
    
    // Checking Peak DC Power per Rack Warranty
    function checkPeakDCPowerPerRackWarranty(uint _tokenId) activated(_tokenId) onlyProvider public {
        
        require(tokenIdToBatteryInfo[_tokenId].isDataReported == true);
        
        bool violationFlag = false;
        uint peakBatteryPower = tokenIdToBatteryInfo[_tokenId].peakDCPower.value;
        if (peakBatteryPower > peak_dc_rack_power) {
            tokenIdToBatteryInfo[_tokenId].peakDCPower.violationFlag = true;
            violationFlag = true;
        }
        
        tokenIdToBatteryInfo[_tokenId].warrantyAnalysisInfo.peakDCPowerViolation = violationFlag;
    }
    
    // Checking Daily Average DC Power Warranty
    function checkDailyAverageDCPowerWarranty(uint _tokenId) activated(_tokenId) onlyProvider public {
        
        require(tokenIdToBatteryInfo[_tokenId].isDataReported == true);

        bool violationFlag = false;
        uint dailyAverageDCPower = tokenIdToBatteryInfo[_tokenId].dailyAverageDCPower.value;
        if (dailyAverageDCPower > daily_avg_rack_power) {
            tokenIdToBatteryInfo[_tokenId].dailyAverageDCPower.violationFlag = true;
            violationFlag = true;
        }
        
        tokenIdToBatteryInfo[_tokenId].warrantyAnalysisInfo.dailyAverageDCPowerViolation = violationFlag;
    }
    
    // Update warranty status if any violation is detected
    function updateWarranty(uint _tokenId) activated(_tokenId) onlyProvider public {
        
        require(tokenIdToBatteryInfo[_tokenId].isWarrantyAnalyzed == true);
        
        WarrantyAnalysisInfo wInfo = tokenIdToBatteryInfo[_tokenId].warrantyAnalysisInfo;
        
        bool warrantyViolation = false;
        
        if (wInfo.annualAverageSOCViolation == true || wInfo.annualAccumulatedDischargeEnergyViolation == true || wInfo.peakDCPowerViolation == true || wInfo.dailyAverageDCPowerViolation == true) {
            warrantyViolation = true;
        }
        
        if (warrantyViolation == true) {
            tokenIdToBatteryInfo[_tokenId].warrantyStatus = WarrantyStatus.OUT_OF_WARRANTY;
        } else {
            tokenIdToBatteryInfo[_tokenId].warrantyStatus = WarrantyStatus.UNDER_WARRANTY;
        }
    }

    function testProduceBatteryAndEMSProvider() public {
        
        registerTrustedEMSProvider(0x14723a09acff6d2a60dcdf7aa4aff308fddc160c);
        
        // 1 eth ~= 130 as of 3/12/2019
        produceBattery("testBattery1", 170, 100, 80, 2019, 3);

    }
    
    //TODO need modifier
    function modifyWarrantyState(uint _tokenId, WarrantyStatus status) onlyProvider public {
        
        BatteryInfo storage bInfo = tokenIdToBatteryInfo[_tokenId];
        bInfo.warrantyStatus = status;

    }

    function showBatteryInfo(uint _tokenId) public constant returns (string batteryID, address owner, address emsProvider, uint price, uint bolCapacity, uint maxPower, string stateIs, string warrantyStatus, uint currentYear, uint warrantyPeriod) {
        BatteryInfo storage bInfo = tokenIdToBatteryInfo[_tokenId];
        uint bstate = uint(bInfo.state);
        uint wstatus = uint(bInfo.warrantyStatus);

        // PRODUCED, FORSALE, SOLD, INSTALLED, MANAGED, RETURNED}
        if (bstate == 0) {
            stateIs = "Default";
        } else if (bstate == 1) {
            stateIs = "Produced";
        } else if (bstate == 2) {
            stateIs = "ForSale";
        } else if (bstate == 3) {
            stateIs = "Sold";
        } else if (bstate == 4) {
            stateIs = "Installed";
        } else if (bstate == 5) {
            stateIs = "Managed";
        } else if (bstate == 6) {
            stateIs = "Active";
        } else if (bstate == 7) {
            stateIs = "Returned";
        } else {
            stateIs = "Undefined";
        }
        
        if (wstatus == 0) {
            warrantyStatus = "Under Warranty";
        } else if (wstatus == 1) {
            warrantyStatus = "Out of Warranty";
        } 
         
        return (
            bInfo.batteryID, 
            bInfo.owner,
            bInfo.emsProvider,
            bInfo.price,
            bInfo.bolCapacity,
            bInfo.maxPower,
            stateIs,
            warrantyStatus,
            bInfo.currentYear,
            bInfo.warrantyPeriod
        );
    }
    
    function showBatteryDataReportStatus(uint _tokenId) public constant returns (bool isDataReported) {
        return ( tokenIdToBatteryInfo[_tokenId].isDataReported );
    }

    function showBatteryWarrantyAnalyzeStatus(uint _tokenId) public constant returns (bool isWarrantyAnalyzed) {
        return ( tokenIdToBatteryInfo[_tokenId].isWarrantyAnalyzed );
    }

    function showBatteryViolationInfo(uint _tokenId) public constant returns (string batteryID, address owner, address emsProvider, bool annualAverageSOCViolation, bool annualAccumulatedDischargeEnergyViolation, bool peakDCPowerViolation, bool dailyAverageDCPowerViolation) {
        BatteryInfo storage bInfo = tokenIdToBatteryInfo[_tokenId];
        
        return (
            bInfo.batteryID, 
            bInfo.owner,
            bInfo.emsProvider,
            bInfo.warrantyAnalysisInfo.annualAverageSOCViolation,
            bInfo.warrantyAnalysisInfo.annualAccumulatedDischargeEnergyViolation,
            bInfo.warrantyAnalysisInfo.peakDCPowerViolation,
            bInfo.warrantyAnalysisInfo.dailyAverageDCPowerViolation
            //bInfo.warrantyAnalysisInfo.averageHourlyTemperatureViolation,
            //bInfo.test[2013]
        );
    }

    function showAnnualAverageSOC(uint _tokenId, uint _year) public constant returns (uint TokenID, uint year, uint annualAverageSOC, bool annualAverageSOCViolation) {
        
        //AnnualAverageSOC[] socInfoList = tokenIdToAnnualAverageSOCList[_tokenId];
        AnnualAverageSOC socInfo = tokenIdToBatteryInfo[_tokenId].annualAverageSOC;
        
        return (
            _tokenId,
            socInfo.year,
            socInfo.value,
            socInfo.violationFlag
        );
    }
    
    function showVariables(uint _tokenId) public constant returns (uint Max_Average_Soc, uint Peak_DC_Rack_Power, uint Daily_Avg_Rack_Power, uint Annual_Accum_Disch_Energy) {
        return (
            max_average_soc,
            peak_dc_rack_power,
            daily_avg_rack_power,
            tokenIdToBatteryInfo[_tokenId].annual_accum_disch_energy
        );
    }
}