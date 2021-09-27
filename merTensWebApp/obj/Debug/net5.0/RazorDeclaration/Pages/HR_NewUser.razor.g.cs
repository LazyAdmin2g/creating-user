// <auto-generated/>
#pragma warning disable 1591
#pragma warning disable 0414
#pragma warning disable 0649
#pragma warning disable 0169

namespace merTensWebApp.Pages
{
    #line hidden
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using Microsoft.AspNetCore.Components;
#nullable restore
#line 1 "H:\Dev\Projekte\creating-user\merTensWebApp\_Imports.razor"
using System.Net.Http;

#line default
#line hidden
#nullable disable
#nullable restore
#line 2 "H:\Dev\Projekte\creating-user\merTensWebApp\_Imports.razor"
using Microsoft.AspNetCore.Authorization;

#line default
#line hidden
#nullable disable
#nullable restore
#line 3 "H:\Dev\Projekte\creating-user\merTensWebApp\_Imports.razor"
using Microsoft.AspNetCore.Components.Authorization;

#line default
#line hidden
#nullable disable
#nullable restore
#line 4 "H:\Dev\Projekte\creating-user\merTensWebApp\_Imports.razor"
using Microsoft.AspNetCore.Components.Forms;

#line default
#line hidden
#nullable disable
#nullable restore
#line 5 "H:\Dev\Projekte\creating-user\merTensWebApp\_Imports.razor"
using Microsoft.AspNetCore.Components.Routing;

#line default
#line hidden
#nullable disable
#nullable restore
#line 6 "H:\Dev\Projekte\creating-user\merTensWebApp\_Imports.razor"
using Microsoft.AspNetCore.Components.Web;

#line default
#line hidden
#nullable disable
#nullable restore
#line 7 "H:\Dev\Projekte\creating-user\merTensWebApp\_Imports.razor"
using Microsoft.AspNetCore.Components.Web.Virtualization;

#line default
#line hidden
#nullable disable
#nullable restore
#line 8 "H:\Dev\Projekte\creating-user\merTensWebApp\_Imports.razor"
using Microsoft.JSInterop;

#line default
#line hidden
#nullable disable
#nullable restore
#line 9 "H:\Dev\Projekte\creating-user\merTensWebApp\_Imports.razor"
using merTensWebApp;

#line default
#line hidden
#nullable disable
#nullable restore
#line 10 "H:\Dev\Projekte\creating-user\merTensWebApp\_Imports.razor"
using merTensWebApp.Shared;

#line default
#line hidden
#nullable disable
#nullable restore
#line 11 "H:\Dev\Projekte\creating-user\merTensWebApp\_Imports.razor"
using Blazorise;

#line default
#line hidden
#nullable disable
#nullable restore
#line 12 "H:\Dev\Projekte\creating-user\merTensWebApp\_Imports.razor"
using System.Management.Automation;

#line default
#line hidden
#nullable disable
#nullable restore
#line 13 "H:\Dev\Projekte\creating-user\merTensWebApp\_Imports.razor"
using System.Management;

#line default
#line hidden
#nullable disable
#nullable restore
#line 14 "H:\Dev\Projekte\creating-user\merTensWebApp\_Imports.razor"
using System.Management.Automation.Runspaces;

#line default
#line hidden
#nullable disable
#nullable restore
#line 15 "H:\Dev\Projekte\creating-user\merTensWebApp\_Imports.razor"
using System.DirectoryServices;

#line default
#line hidden
#nullable disable
#nullable restore
#line 16 "H:\Dev\Projekte\creating-user\merTensWebApp\_Imports.razor"
using System.Diagnostics;

#line default
#line hidden
#nullable disable
#nullable restore
#line 17 "H:\Dev\Projekte\creating-user\merTensWebApp\_Imports.razor"
using Microsoft.PowerShell;

#line default
#line hidden
#nullable disable
#nullable restore
#line 18 "H:\Dev\Projekte\creating-user\merTensWebApp\_Imports.razor"
using System.Collections;

#line default
#line hidden
#nullable disable
#nullable restore
#line 19 "H:\Dev\Projekte\creating-user\merTensWebApp\_Imports.razor"
using System.Threading.Tasks;

#line default
#line hidden
#nullable disable
#nullable restore
#line 20 "H:\Dev\Projekte\creating-user\merTensWebApp\_Imports.razor"
using System.Text;

#line default
#line hidden
#nullable disable
#nullable restore
#line 3 "H:\Dev\Projekte\creating-user\merTensWebApp\Pages\HR_NewUser.razor"
using DataLibrary;

#line default
#line hidden
#nullable disable
#nullable restore
#line 4 "H:\Dev\Projekte\creating-user\merTensWebApp\Pages\HR_NewUser.razor"
using DataLibrary.Models;

#line default
#line hidden
#nullable disable
#nullable restore
#line 5 "H:\Dev\Projekte\creating-user\merTensWebApp\Pages\HR_NewUser.razor"
using merTensWebApp.Models;

#line default
#line hidden
#nullable disable
#nullable restore
#line 6 "H:\Dev\Projekte\creating-user\merTensWebApp\Pages\HR_NewUser.razor"
using System.Collections.ObjectModel;

#line default
#line hidden
#nullable disable
#nullable restore
#line 7 "H:\Dev\Projekte\creating-user\merTensWebApp\Pages\HR_NewUser.razor"
using Blazorise.Components;

#line default
#line hidden
#nullable disable
    [Microsoft.AspNetCore.Components.RouteAttribute("/HR/User")]
    public partial class HR_NewUser : Microsoft.AspNetCore.Components.ComponentBase
    {
        #pragma warning disable 1998
        protected override void BuildRenderTree(Microsoft.AspNetCore.Components.Rendering.RenderTreeBuilder __builder)
        {
        }
        #pragma warning restore 1998
#nullable restore
#line 117 "H:\Dev\Projekte\creating-user\merTensWebApp\Pages\HR_NewUser.razor"
       
    //Liste für Stellenbeschreibung
    static string[] merTensStellen = { "KAM", "AM", "LAGER"};
    IEnumerable<Stellenbeschreibung> stellen = Enumerable.Range(1, merTensStellen.Length).Select(x => new Stellenbeschreibung { MyTextField = merTensStellen[x - 1], MyValueField = x });
    int selectedListValue { get; set; }
    int selectedDropValue { get; set; } = 2;

    void MyListValueChangedHandler(int newValue)
    {
        selectedListValue = newValue;
    }



    //Liste für User
    private List<UserModel> user;
    private DisplayUserModel newUser = new DisplayUserModel();


    //Switch Vars
    private bool nbChecked;
    private bool handyChecked;
    private bool tabletChecked;
    private bool monChecked;
    private bool printerChecked;
    private bool homeChecked;

    //Modal Vars
    private Modal modalRef;
    private bool centered = false;
    private ModalSize modalSize = ModalSize.Default;
    private int? maxHeight = null;

    private void switchCheck()
    {
        if (nbChecked == true) { newUser.Notebook = "1"; }
        else { newUser.Notebook = "0"; }

        if (handyChecked == true) { newUser.Handy = "1"; }
        else { newUser.Handy = "0"; }

        if (tabletChecked == true) { newUser.Tablet = "1"; }
        else { newUser.Tablet = "0"; }

        if (monChecked == true) { newUser.Monitor = "1"; }
        else { newUser.Monitor = "0"; }

        if (printerChecked == true) { newUser.Drucker = "1"; }
        else { newUser.Drucker = "0"; }

        if (homeChecked == true) { newUser.Homeoffice = "1"; }
        else { newUser.Homeoffice = "0"; }
    }


    private void ShowModal(ModalSize modalSize, int? maxHeight = null, bool centered = false, bool nbChecked = false, bool handyChecked = false, bool tabletChecked = false, bool monChecked = false, bool printerChecked = false, bool homeChecked = false)
    {
        this.centered = centered;
        this.modalSize = modalSize;
        this.maxHeight = maxHeight;
        this.nbChecked = false;
        this.handyChecked = false;
        this.tabletChecked = false;
        this.monChecked = false;
        this.printerChecked = false;
        this.homeChecked = false;
        //this.strStellenbeschreibung = "";

        modalRef.Show();
    }

    private void HideModal()
    {
        modalRef.Hide();
    }

    protected override async Task OnInitializedAsync()
    {
        user = await _db.GetUsers();
    }

    private async Task CreateUser()
    {
        switchCheck();
        UserModel u = new UserModel
        {

            Vorname = newUser.Vorname,
            Nachname = newUser.Nachname,
            Username = newUser.Vorname.Substring(0, 1).ToLower() + "." + newUser.Nachname.ToLower(),
            Email = newUser.Vorname.Substring(0, 1).ToLower() + "." + newUser.Nachname.ToLower() + "@mertens.ag",
            Stellenbeschreibung = newUser.Stellenbeschreibung,
            Eintrittsdatum = newUser.Eintrittsdatum,
            INT_TODO = newUser.INT_TODO,
            Notebook = newUser.Notebook,
            Handy = newUser.Handy,
            Tablet = newUser.Tablet,
            Monitor = newUser.Monitor,
            Drucker = newUser.Drucker,
            Homeoffice = newUser.Homeoffice
        };
        await _db.NewUser(u);

        user.Add(u);

        newUser = new DisplayUserModel();
        HideModal();
    }

#line default
#line hidden
#nullable disable
        [global::Microsoft.AspNetCore.Components.InjectAttribute] private IUserData _db { get; set; }
    }
}
#pragma warning restore 1591