/*we going to handle the request and responses and from controllers folder we are going to hit the service folder*/
const UserService = require('../services/user_services');

//--------------------------------------------------------------------------------------

exports.register = async (req, res, next) => {
    try {
        const { userName, email, password, role } = req.body;
        
        // Validate input here if not done in UserService
        const user = await UserService.registerUser(userName, email, password, role);
        
        // Assuming UserService.registerUser returns the saved user without password
        // Map the user to exclude sensitive information if needed
        const userResponse = {
            userName: user.userName,
            email: user.email,
            role: user.role,
        };

        res.status(201).json({
            status: true,
            message: "User Registered Successfully",
            user: userResponse,
        });
    } catch (error) {
        // Improved error handling
        console.error("Registration Error:", error);
        res.status(500).json({
            status: false,
            error: "Server Error, Registration Failed",
        });
    }
};

//--------------------------------------------------------------------------------------

exports.login = async (req, res, next) => {
    try {
        const { email, password } = req.body;

        const user = await UserService.checkUser(email);

        if (!user) {
            return res.status(404).json({
                status: false,
                error: 'User does not exist',
            });
        }

        const isMatch = await user.comparePassword(password);
        
        if (!isMatch) {
            return res.status(401).json({
                status: false,
                error: 'Invalid credentials',
            });
        }

        // Use environment variable for secret key
        const secretKey = process.env.JWT_SECRET_KEY || 'default_secret_key'; 
        // Ensure you have a better default or force the environment variable
        const token = await UserService.generateToken({
            _id: user._id,
            userName: user.userName,
            email: user.email,
            role: user.role,
        }, secretKey, '1h');

        res.status(200).json({
            status: true,
            token,
        });
    } catch (error) {
        console.error("Login Error:", error);
        res.status(500).json({
            status: false,
            error: "Server Error, Login Failed",
        });
    }
};

//--------------------------------------------------------------------------------------

