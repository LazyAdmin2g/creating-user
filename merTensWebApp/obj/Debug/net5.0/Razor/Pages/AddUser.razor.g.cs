#pragma checksum "H:\Dev\Projekte\creating-user\merTensWebApp\Pages\AddUser.razor" "{ff1816ec-aa5e-4d10-87f7-6f4963833460}" "75769727a500e8b7c333e8444334e097071c3e2e"
// <auto-generated/>
#pragma warning disable 1591
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
#line 21 "H:\Dev\Projekte\creating-user\merTensWebApp\_Imports.razor"
using merTensWebApp.Models;

#line default
#line hidden
#nullable disable
#nullable restore
#line 2 "H:\Dev\Projekte\creating-user\merTensWebApp\Pages\AddUser.razor"
using merTensWebApp.Data;

#line default
#line hidden
#nullable disable
#nullable restore
#line 3 "H:\Dev\Projekte\creating-user\merTensWebApp\Pages\AddUser.razor"
using merTensWebApp.Shared;

#line default
#line hidden
#nullable disable
    [Microsoft.AspNetCore.Components.RouteAttribute("/AddUser")]
    public partial class AddUser : Microsoft.AspNetCore.Components.ComponentBase
    {
        #pragma warning disable 1998
        protected override void BuildRenderTree(Microsoft.AspNetCore.Components.Rendering.RenderTreeBuilder __builder)
        {
            __builder.AddMarkupContent(0, "<h2>Mitarbeiter hinzufügen</h2>\r\n\r\n");
            __builder.OpenElement(1, "form");
            __builder.OpenElement(2, "div");
            __builder.AddAttribute(3, "class", "row");
            __builder.OpenElement(4, "div");
            __builder.AddAttribute(5, "class", "col-md-8");
            __builder.OpenElement(6, "div");
            __builder.AddAttribute(7, "class", "form-group");
            __builder.AddMarkupContent(8, "<label for=\"Vorname\" class=\"control-label\">Vorname</label>\r\n                ");
            __builder.OpenElement(9, "input");
            __builder.AddAttribute(10, "form", "Vorname");
            __builder.AddAttribute(11, "class", "form-control");
            __builder.AddAttribute(12, "value", Microsoft.AspNetCore.Components.BindConverter.FormatValue(
#nullable restore
#line 14 "H:\Dev\Projekte\creating-user\merTensWebApp\Pages\AddUser.razor"
                                                                   objUser.Vorname

#line default
#line hidden
#nullable disable
            ));
            __builder.AddAttribute(13, "onchange", Microsoft.AspNetCore.Components.EventCallback.Factory.CreateBinder(this, __value => objUser.Vorname = __value, objUser.Vorname));
            __builder.SetUpdatesAttributeName("value");
            __builder.CloseElement();
            __builder.CloseElement();
            __builder.AddMarkupContent(14, "\r\n            ");
            __builder.OpenElement(15, "div");
            __builder.AddAttribute(16, "class", "form-group");
            __builder.AddMarkupContent(17, "<label for=\"Stellenbeschreibung\" class=\"control-label\"></label>\r\n                ");
            __builder.OpenElement(18, "select");
            __builder.AddAttribute(19, "class", "form-control");
            __builder.AddAttribute(20, "value", Microsoft.AspNetCore.Components.BindConverter.FormatValue(
#nullable restore
#line 18 "H:\Dev\Projekte\creating-user\merTensWebApp\Pages\AddUser.razor"
                                objUser.Stellenbeschreibung

#line default
#line hidden
#nullable disable
            ));
            __builder.AddAttribute(21, "onchange", Microsoft.AspNetCore.Components.EventCallback.Factory.CreateBinder(this, __value => objUser.Stellenbeschreibung = __value, objUser.Stellenbeschreibung));
            __builder.SetUpdatesAttributeName("value");
            __builder.OpenElement(22, "option");
            __builder.AddAttribute(23, "value");
            __builder.AddMarkupContent(24, "-- Bitte wähle die Abteilung--");
            __builder.CloseElement();
            __builder.AddMarkupContent(25, "\r\n                    ");
            __builder.OpenElement(26, "option");
            __builder.AddAttribute(27, "value", "KAM");
            __builder.AddContent(28, "KAM");
            __builder.CloseElement();
            __builder.CloseElement();
            __builder.CloseElement();
            __builder.CloseElement();
            __builder.CloseElement();
            __builder.CloseElement();
        }
        #pragma warning restore 1998
#nullable restore
#line 27 "H:\Dev\Projekte\creating-user\merTensWebApp\Pages\AddUser.razor"
       
    Model_HR_User_Anlage objUser = new Model_HR_User_Anlage();

    protected void CreateUser()
    {
        objUserService.Create(objUser);
        NavigationManager.NavigateTo("HR_User-Anlage");
    }
    void Cancel()
    {
        NavigationManager.NavigateTo("HR_User-Anlage");
    }


#line default
#line hidden
#nullable disable
        [global::Microsoft.AspNetCore.Components.InjectAttribute] private HR_UserService objUserService { get; set; }
        [global::Microsoft.AspNetCore.Components.InjectAttribute] private NavigationManager NavigationManager { get; set; }
    }
}
#pragma warning restore 1591