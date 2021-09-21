﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace merTensWebApp.Models
{
    public class DBModels_MAG_Mitarbeiter
    {
        public int UID { get; set; }
        public string Vorname { get; set; }
        public string Nachname { get; set; }
        public string eMail { get; set; }
        public string Stellenbeschreibung { get; set; }
        public DateTime Eintrittsdatum { get; set; }
        public bool INT_Todo { get; set; }
        public bool Notebook { get; set; }
        public bool Handy { get; set; }
        public bool Tablet { get; set; }
        public bool Monitor { get; set; }
        public bool Drucker { get; set; }
        public bool Homeoffice { get; set; }
    }
}
