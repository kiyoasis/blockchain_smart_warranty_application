const SupplyChain = artifacts.require('SupplyChain')

contract('SupplyChain', accounts => {

    const batteryProvider = accounts[0];
    const EMSProvider = accounts[1];
    const batteryUser = accounts[2];
    const tokenId = 1;
    const batteryID = "testBattery1";
    const capacity = 170;
    const maxPower = 100;
    const price = 80;
    const year = 2019;
    const warrantyPeriod = 3;
    const emptyAddress = '0x0000000000000000000000000000000000000000'

    beforeEach(async function() { 
        this.contract = await SupplyChain.new({from: accounts[0]})
    })
    
    describe('can produce and add a battery by the battery producer', () => {

        it('can produce a battery and all the info is registered', async function () { 
            
            // 1 eth ~= 130 as of 3/12/2019
            await this.contract.produceBattery(batteryID, capacity, maxPower, price, year, warrantyPeriod, {from: batteryProvider});
            const batteryInfo = await this.contract.showBatteryInfo.call(tokenId);

            assert.equal(batteryInfo[0], batteryID, 'Error: Invalid Battery ID');
            assert.equal(batteryInfo[1], emptyAddress, 'Error: Invalid Owner');
            assert.equal(batteryInfo[2], emptyAddress, 'Error: Invalid EMS Provider');
            assert.equal(batteryInfo[3], price, 'Error: Invalid price');
            assert.equal(batteryInfo[4], capacity, 'Error: Invalid capacity');
            assert.equal(batteryInfo[5], maxPower, 'Error: Invalid max power');
            assert.equal(batteryInfo[6], 'Produced', 'Error: Invalid battery state');
            assert.equal(batteryInfo[7], 'Under Warranty', 'Error: Invalid warranty status');
            assert.equal(batteryInfo[8], year, 'Error: Invalid year');
            assert.equal(batteryInfo[9], warrantyPeriod, 'Error: Invalid warranty period');

            //assert.equal(await this.contract.showBatteryInfo(tokenId), ['testBattery1', emptyAddress, emptyAddress, price, capacity, maxPower, "Produced", "Under Warranty", year, warrantyPeriod]);
        })

        it('can add an item, which is the produced battery', async function () {
            await this.contract.produceBattery(batteryID, capacity, maxPower, price, year, warrantyPeriod, {from: batteryProvider});
            await this.contract.addItem(tokenId, {from: batteryProvider});

            const batteryInfo = await this.contract.showBatteryInfo.call(tokenId);
            assert.equal(batteryInfo[6], 'ForSale', 'Error: Invalid battery state');
        })
    })

    describe('can buy and install a battery by the battery user', () => { 

        it('The buttery user can buy the battery for sale from the provider and check the owner and state are updated', async function() {
            await this.contract.produceBattery(batteryID, capacity, maxPower, price, year, warrantyPeriod, {from: batteryProvider});
            await this.contract.addItem(tokenId, {from: batteryProvider});

            await this.contract.buyItem(tokenId, {from: batteryUser, value: price});
            const batteryInfo = await this.contract.showBatteryInfo.call(tokenId);
            assert.equal(batteryInfo[1], batteryUser, 'Error: Invalid battery user/owner');
            assert.equal(batteryInfo[6], 'Sold', 'Error: Invalid battery state');
        })

        it('The buttery user can install the sold battery and check the owner of the battery state is updated', async function() {
            await this.contract.produceBattery(batteryID, capacity, maxPower, price, year, warrantyPeriod, {from: batteryProvider});
            await this.contract.addItem(tokenId, {from: batteryProvider});
            await this.contract.buyItem(tokenId, {from: batteryUser, value: price});

            await this.contract.installBattery(tokenId, {from: batteryUser});
            const batteryInfo = await this.contract.showBatteryInfo.call(tokenId);
            assert.equal(batteryInfo[6], 'Installed', 'Error: Invalid battery state');
        })

    })

    describe('can manage a battery by the battery provider', () => { 

        it('The buttery provider can assign an EMS provider and check the EMS provider and state of the battery state are updated', async function() {
            await this.contract.produceBattery(batteryID, capacity, maxPower, price, year, warrantyPeriod, {from: batteryProvider});
            await this.contract.addItem(tokenId, {from: batteryProvider});
            await this.contract.buyItem(tokenId, {from: batteryUser, value: price});
            await this.contract.installBattery(tokenId, {from: batteryUser});

            await this.contract.manageBattery(tokenId, EMSProvider, {from: batteryProvider});
            const batteryInfo = await this.contract.showBatteryInfo.call(tokenId);
            assert.equal(batteryInfo[2], EMSProvider, 'Error: Invalid EMS Provider');
            assert.equal(batteryInfo[6], 'Managed', 'Error: Invalid battery state');
        })
    })

    describe('can utilize a battery by the EMS provider', () => { 

        it('The EMS provider can utilize a battery to make it active. Check the state of the battery is updated to active', async function() {
            await this.contract.produceBattery(batteryID, capacity, maxPower, price, year, warrantyPeriod, {from: batteryProvider});
            await this.contract.addItem(tokenId, {from: batteryProvider});
            await this.contract.buyItem(tokenId, {from: batteryUser, value: price});
            await this.contract.installBattery(tokenId, {from: batteryUser});
            await this.contract.manageBattery(tokenId, EMSProvider, {from: batteryProvider});

            await this.contract.utilizeBattery(tokenId, {from: EMSProvider});
            const batteryInfo = await this.contract.showBatteryInfo.call(tokenId);
            assert.equal(batteryInfo[6], 'Active', 'Error: Invalid battery state');
        })
    })

    describe('can get usage data of the battery by the EMS provider', () => { 

        const _month = 3;
        const _day = 15;
        const _hour = 14;
        const _socValue = 60;
        const _aade = 100000;
        const _peakDCPower = 30;
        const _averageDailyDCPower = 40;

        it('The EMS provider can obtain battery usage data for warranty analysis. Check the data report status of the battery is updated to true', async function() {
            await this.contract.produceBattery(batteryID, capacity, maxPower, price, year, warrantyPeriod, {from: batteryProvider});
            await this.contract.addItem(tokenId, {from: batteryProvider});
            await this.contract.buyItem(tokenId, {from: batteryUser, value: price});
            await this.contract.installBattery(tokenId, {from: batteryUser});
            await this.contract.manageBattery(tokenId, EMSProvider, {from: batteryProvider});
            await this.contract.utilizeBattery(tokenId, {from: EMSProvider});

            await this.contract.getUsageData(tokenId, year, _month, _day, _hour, _socValue, _aade, _peakDCPower, _averageDailyDCPower, {from: EMSProvider});
            const isDataReported = await this.contract.showBatteryDataReportStatus.call(tokenId);
            assert.equal(isDataReported, true, 'Error: Invalid data report status');
        })
    })

    describe('can analyze and update warranty violation of the battery by the provider', () => { 

        const _month = 3;
        const _day = 15;
        const _hour = 14;
        const _socValue = 60;
        const _aade = 100000;
        const _peakDCPower = 30;
        const _averageDailyDCPower = 40;

        it('The battery provider can check the warranty violation of the battery. Check the state of the data report state is updated and only the average SOC term is violated.', async function() {
            await this.contract.produceBattery(batteryID, capacity, maxPower, price, year, warrantyPeriod, {from: batteryProvider});
            await this.contract.addItem(tokenId, {from: batteryProvider});
            await this.contract.buyItem(tokenId, {from: batteryUser, value: price});
            await this.contract.installBattery(tokenId, {from: batteryUser});
            await this.contract.manageBattery(tokenId, EMSProvider, {from: batteryProvider});
            await this.contract.utilizeBattery(tokenId, {from: EMSProvider});
            await this.contract.getUsageData(tokenId, year, _month, _day, _hour, _socValue, _aade, _peakDCPower, _averageDailyDCPower, {from: EMSProvider});

            await this.contract.checkWarranty(tokenId, {from: batteryProvider});
            const isWarrantyAnalyzed = await this.contract.showBatteryWarrantyAnalyzeStatus.call(tokenId);
            const batteryViolationInfo = await this.contract.showBatteryViolationInfo.call(tokenId);
            assert.equal(isWarrantyAnalyzed, true, 'Error: Invalid warranty analysis status');
            assert.equal(batteryViolationInfo[3], true, 'Error: Calculation of warranty analysis of annual average SOC is wrong');
            assert.equal(batteryViolationInfo[4], false, 'Error: Calculation of warranty analysis of AADE is wrong');
            assert.equal(batteryViolationInfo[5], false, 'Error: Calculation of warranty analysis of peak DC Power is wrong');
            assert.equal(batteryViolationInfo[6], false, 'Error: Calculation of warranty analysis of average daily DC power is wrong');
        })

        it('The battery provider can update the warranty status. As one term is violated, the battery warranty stats should be out of warranty', async function() {
            await this.contract.produceBattery(batteryID, capacity, maxPower, price, year, warrantyPeriod, {from: batteryProvider});
            await this.contract.addItem(tokenId, {from: batteryProvider});
            await this.contract.buyItem(tokenId, {from: batteryUser, value: price});
            await this.contract.installBattery(tokenId, {from: batteryUser});
            await this.contract.manageBattery(tokenId, EMSProvider, {from: batteryProvider});
            await this.contract.utilizeBattery(tokenId, {from: EMSProvider});
            await this.contract.getUsageData(tokenId, year, _month, _day, _hour, _socValue, _aade, _peakDCPower, _averageDailyDCPower, {from: EMSProvider});
            await this.contract.checkWarranty(tokenId, {from: batteryProvider});

            await this.contract.updateWarranty(tokenId, {from: batteryProvider});
            const batteryInfo = await this.contract.showBatteryInfo.call(tokenId);
            assert.equal(batteryInfo[7], 'Out of Warranty', 'Error: Calculation of warranty status is wrong');
        })
    })

})