using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Threading.Tasks;

namespace merTensWebApp.Models
{
    public class DisplayUserModel
    {
        public int ID { get; set; }

        [Required]
        [StringLength(50, ErrorMessage = "Der Name ist zu lang")]
        [MinLength(1, ErrorMessage = "Der Name ist zu kurz")]
        public string Nachname { get; set; }

        [StringLength(50, ErrorMessage = "Der Name ist zu lang")]
        [MinLength(1, ErrorMessage = "Der Name ist zu kurz")]
        public string Vorname { get; set; }

        public string Username { get; set; }
        public string Email { get; set; }

        public string Stellenbeschreibung { get; set; }

        public DateTime? Eintrittsdatum { get; set; }

        public string INT_TODO { get; set; }
        public string Notebook { get; set; }
        public string Handy { get; set; }
        public string Tablet { get; set; }
        public string Monitor { get; set; }
        public string Drucker { get; set; }
        public string Homeoffice { get; set; }
        public DateTime? AngelegtAm { get; set; }
        public string AngelegtVon { get; set; }
    }
}
