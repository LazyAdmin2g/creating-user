using Microsoft.AspNetCore.Authentication;
using Microsoft.IdentityModel.Clients.ActiveDirectory;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Security.Principal;
using System.Threading.Tasks;

namespace merTensWebApp.Data
{
    public class UserAuthorizationService : IClaimsTransformation
    {
        public UserInfo userInfo;

        private ClaimsPrincipal CustomClaimsPrincipal;

        public Task<ClaimsPrincipal> TransformAsync(ClaimsPrincipal principal)
        {
            //Creates UserInfo Object on the first Call Only
            if (userInfo == null)
                userInfo = new UserInfo((principal.Identity as WindowsIdentity).Owner.Value);

            //Establishes CustomClaimsPrincipal on first Call
            if (CustomClaimsPrincipal == null)
            {
                CustomClaimsPrincipal = principal;
                var claimsIdentity = new ClaimsIdentity();

                //Loop through AD Group list and applies policies
                foreach (var group in userInfo.ADGroups)
                {
                    switch (group)
                    {
                        case "BG_MAG_HR":
                            claimsIdentity.AddClaim(new Claim(ClaimTypes.Role, "HR"));
                            break;
                        case "BG_MAG_IT":
                            claimsIdentity.AddClaim(new Claim(ClaimTypes.Role, "IT"));
                            break;
                    }
                }
                CustomClaimsPrincipal.AddIdentity(claimsIdentity);
            }

            return Task.FromResult(CustomClaimsPrincipal);
        }
    }
}
