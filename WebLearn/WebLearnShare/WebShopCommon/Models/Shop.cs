﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WebShopCommon.Models
{
    public class Shop
    {
        public Guid Id { get; set; }
        public string Name { get; set; }

        public Guid ImageId { get; set; }

        public decimal Price { get; set; }

    }
}
