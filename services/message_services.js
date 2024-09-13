const Message = require('../model/message_model');

class MessageService {
  static async createMessage(chatId, senderId, senderType, messageType, messageContent) {
    const message = new Message({
      chatId,
      senderId,
      senderType,
      messageType,
      messageContent,
      createdAt: new Date(),
    });
    return await message.save();
  }

  static async getMessagesByChatId(chatId) {
    return await Message.find({ chatId }).sort({ createdAt: 1 });
  }
}

module.exports = MessageService;
