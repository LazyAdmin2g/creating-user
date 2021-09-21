using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;
using Dapper;
using merTensWebApp.Models;

namespace merTensWebApp.Data
{
    public class HR_UserService
    {
        private string conString = "";
        public HR_UserService()
        {
            conString = @"Data Source=MAGVSQ03;Initial Catalog=myAPP;Persist Security Info=True;User ID=sa;Password=M3rt3ns.@G";
        }

        public IDbConnection Connection
        {
            get
            {
                return new SqlConnection(conString);
            }
        }

        public void Create(Model_HR_User_Anlage user)
        {
            using (IDbConnection dbConnection = Connection)
            {
                string sQuery = @"INSERT INTO User_HRAnlage_IMP (Vorname, Nachname, Username, Email, Stellenbeschreibung) VALUES (@Vorname, @Nachname, @Username, @Email, @Stellenbeschreibung)";
                dbConnection.Open();
                dbConnection.Execute(sQuery, user);
            }
        }

        public async Task<IEnumerable<Model_HR_User_Anlage>> GetUser()
        {
            try
            {
                using (IDbConnection dbConnection = Connection)
                {
                    dbConnection.Open();
                    return await dbConnection.QueryAsync<Model_HR_User_Anlage>("SELECT * FROM User_HRAnlage_IMP");
                }
            }
            catch(Exception)
            {
                throw;
            }
        }

        public Model_HR_User_Anlage GetUserByID(int id)
        {
            using (IDbConnection dbConnection = Connection)
            {
                string sQuery = @"SELECT * FROM User_HRAnlage_IMP WHERE ID=@ID";
                dbConnection.Open();
                return dbConnection.Query<Model_HR_User_Anlage>(sQuery, new { ID = id }).FirstOrDefault();
            }
        }
    }
}
