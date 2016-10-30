﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Algorithm.String
{
    /// <summary>
    /// Kunth-Morris-Pratt
    /// </summary>
    public class KmpMatcher
    {
        public IList<int> ComputePrefixFunction(string pattern)
        {
            var length = pattern.Length;

            var prefixFunction = new int[length];

            //用-1表示0，因为索引从0开始。-1表示不存在。
            var k = -1;
            prefixFunction[0] = -1;

            for (int q= 1; q < length; q++)
            {
                while (k > -1 && pattern[k + 1] != pattern[q])
                {
                    k = prefixFunction[k];
                }
                if (pattern[k+1] == pattern[q])
                {
                    k = k + 1;
                }
                prefixFunction[q] = k;
            }

       
            return prefixFunction;

        }
    }
}
