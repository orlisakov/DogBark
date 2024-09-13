/*we are going to perform all the database operation*/
const { TrainerModel, OwnerModel, AdminModel } = require('../model/user_model');

const jwt = require('jsonwebtoken');

class UserService {
    //---------------register-------------------------
    static async registerUser(userName, email, password, role) {
        try {
            let user;
            if (role === 'owner') {
                user = new OwnerModel({ userName, email, password, role });
            } else if (role === 'trainer') {
                user = new TrainerModel({ userName, email, password, role });
            } else {
                throw new Error('Invalid role');
            }
            return await user.save();

        } catch (err) {
            throw err;
        }
    }

    //---------------login-------------------------

    // Check user by email
    static async checkUser(email) {
        try {
            // Check both OwnerModel and TrainerModel
            return await OwnerModel.findOne({ email }) || await TrainerModel.findOne({ email }) || await AdminModel.findOne({ email });
        } catch (error) {
            throw error;
        }
    }
    

    static async generateToken(tokenData, secretKey, jwt_expire) {
        return jwt.sign(tokenData, secretKey, {expiresIn: jwt_expire});
    }
}

module.exports = UserService;