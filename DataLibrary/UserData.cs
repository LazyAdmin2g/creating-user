using DataLibrary.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DataLibrary
{
    public class UserData : IUserData
    {
        private readonly ISqlDataAccess _db;

        public UserData(ISqlDataAccess db)
        {
            _db = db;
        }

        public Task<List<UserModel>> GetUsers()
        {
            string sql = "SELECT * FROM dbo.User_HRAnlage_IMP";

            return _db.LoadData<UserModel, dynamic>(sql, new { });
        }

        public Task NewUser(UserModel user)
        {
            string sql = @"INSERT INTO dbo.User_HRAnlage_IMP (Vorname, Nachname, Username, Stellenbeschreibung, Email, Eintrittsdatum, INT_Todo, Notebook, Handy, Tablet, Monitor, Drucker, Homeoffice)
                           VALUES (@Vorname, @Nachname, @Username, @Stellenbeschreibung, @Email, @Eintrittsdatum, 1, @Notebook, @Handy, @Tablet, @Monitor, @Drucker, @Homeoffice)";

            return _db.SaveData(sql, user);
        }
    }
}
