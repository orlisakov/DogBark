//additions_services.js
const { Tip } = require('../model/additions_model');

class additionsServices {
    async getAllTips() {
        try {
            return await Tip.find().sort({ createdAt: -1 });
        } catch (error) {
            throw new Error('Error fetching tips: ' + error.message);
        }
    }
    async createTip(tipData) {
        try {
            const tip = new Tip(tipData);
            return await tip.save();
        } catch (error) {
            throw new Error('Error creating tip: ' + error.message);
        }
    }
    async updateTip(id, tipData) {
        try {
            const updatedTip = await Tip.findByIdAndUpdate(id, tipData, { new: true });
            if (!updatedTip) {
                throw new Error('Tip not found');
            }
            return updatedTip;
        } catch (error) {
            throw new Error('Error updating tip: ' + error.message);
        }
    }
    async deleteTip(id) {
        try {
            const deletedTip = await Tip.findByIdAndDelete(id);
            if (!deletedTip) {
                throw new Error('Tip not found');
            }
            return deletedTip;
        } catch (error) {
            throw new Error('Error deleting tip: ' + error.message);
        }
    }
}

module.exports = additionsServices;