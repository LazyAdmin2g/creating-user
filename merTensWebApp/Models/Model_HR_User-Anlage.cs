using System.ComponentModel.DataAnnotations;
using System;
using System.Collections.Generic;

namespace merTensWebApp.Models
{
    public class Model_HR_User_Anlage
    {
        public int ID { get; set; }

        [Required]
        public string Nachname { get; set; }

        [Required]
        public string Vorname { get; set; }

        public string Username { get; set; }
        public string Email { get; set; }

        [Required]
        public string Stellenbeschreibung { get; set; }

        [Required]
        public DateTime? Eintrittsdatum { get; set; }

        public string INT_TODO { get; set; }
        public string Notebook { get; set; }
        public string Handy { get; set; }
        public string Tablet { get; set; }
        public string Monitor { get; set; }
        public string Drucker { get; set; }
        public string Homeoffice { get; set; }

    }
}
