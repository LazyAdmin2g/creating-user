using DataLibrary.Models;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace DataLibrary
{
    public interface IUserData
    {
        Task<List<UserModel>> GetUsers();
        Task NewUser(UserModel user);
    }
}