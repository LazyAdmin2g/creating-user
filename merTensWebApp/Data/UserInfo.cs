using System;
using System.Collections.Generic;
using System.DirectoryServices;
using System.Linq;
using System.Threading.Tasks;

namespace merTensWebApp.Data
{
    public class UserInfo
    {
        private DirectoryEntry User { get; set; }
        public List<string> ADGroups { get; set; }

        public UserInfo(string SID)
        {
            ADGroups = new List<string>();
            //Retrieve Current User 
            using (DirectorySearcher comps = new DirectorySearcher(new DirectoryEntry("OU=merTens,DC=mertens,DC=ag")))
            {
                comps.Filter = "(&(objectClass=user)(objectSID=" + SID + "))";
                User = comps.FindOne().GetDirectoryEntry();
            }
            //Load List with AD Group Names
            foreach (object group in User.Properties["memberOf"])
                ADGroups.Add(group.ToString()[3..].Split(",OU=")[0]);
        }
    }
}
