using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace merTensWebApp.Models
{
    public class DBModels_myAPP
    {
        public int ID { get; set; }
        public string Mandant { get; set; }
        public string Personalnummer { get; set; }
        public string Vorname { get; set; }
        public string Nachname { get; set; }
        public string Username { get; set; }
        public string Anzeigename { get; set; }
        public string Kuerzel { get; set; }
        public string eMail { get; set; }
        public string Position { get; set; }
        public string Buero { get; set; }
        public bool Aktiv { get; set; }
        public DateTime Eintrittsdatum { get; set; }
        public DateTime? Austrittsdatum { get; set; }
        public DateTime AngelegtAm { get; set; }
        public DateTime GeaendertAm { get; set; }
        public string GeaendertVon { get; set; }
        public string GeaendertProg { get; set; }
        public string Bemerkung { get; set; }
        public string UID { get; set; }
    }
}
