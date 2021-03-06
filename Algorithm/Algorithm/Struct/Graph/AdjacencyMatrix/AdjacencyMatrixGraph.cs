﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Algorithm.Struct
{
    public class AdjacencyMatrixGraph<T> where T : IEquatable<T>
    {
        //Array抽象类！需要研究一下。

        private AdjacencyMatrixNode<T>[,] _matrix;

        public AdjacencyMatrixNode<T>[,] Matrix
        {
            get
            {
                return _matrix;
            }
        }

        public int VertexLength
        {
            get
            {
                return _matrix.GetLength(0);
            }
        }

        public AdjacencyMatrixGraph(AdjacencyMatrixNode<T>[,] matrix)
        {
            _matrix = matrix;
        }

        #region Martric

        /// <summary>
        /// 自底上上计算
        /// </summary>
        public AdjacencyMatrixNode<T>[,] SlowAllPairsShortestPath()
        {
            var calcMatrix = _matrix;

            for (int i = 2; i < VertexLength; i++)
            {
                calcMatrix = ExtenedShortestPath(calcMatrix, _matrix);
                PrintMartrix(calcMatrix);
            }

            return calcMatrix;
        }


        /// <summary>
        /// 自底上上计算
        /// </summary>
        public AdjacencyMatrixNode<T>[,] FastAllPairsShortestPath()
        {
            var calcMatrix = _matrix;

            int m = 1;
            while (m < VertexLength - 1)
            {
                calcMatrix = ExtenedShortestPath(calcMatrix, calcMatrix);
                m = 2 * m;
                PrintMartrix(calcMatrix);
            }

            return calcMatrix;
        }





        private AdjacencyMatrixNode<T>[,] ExtenedShortestPath(
            AdjacencyMatrixNode<T>[,] matrix,
             AdjacencyMatrixNode<T>[,] matrixB)
        {
            var length = matrix.GetLength(0);

            var result = new AdjacencyMatrixNode<T>[length, length];

            for (int i = 0; i < length; i++)
            {
                for (int j = 0; j < length; j++)
                {
                    result[i, j] = new AdjacencyMatrixNode<T>();
                    result[i, j].PathWeight = int.MaxValue;

                    for (int k = 0; k < length; k++)
                    {
                        var newPathWeight = Add(matrix[i, k].PathWeight, matrixB[k, j].PathWeight);

                        result[i, j].Predecessor = i;

                        if (newPathWeight < result[i, j].PathWeight)
                        {
                            result[i, j].Predecessor = k;
                        }

                        result[i, j].PathWeight = Math.Min(
                        result[i, j].PathWeight, newPathWeight);

                    }
                }

            }

            return result;
        }

        #endregion


        public AdjacencyMatrixNode<T>[,] FloydWarshall()
        {
            var resultMatrix = _matrix;

            for (int k = 0; k < VertexLength; k++)
            {
                for (int i = 0; i < VertexLength; i++)
                {
                    for (int j = 0; j < VertexLength; j++)
                    {
                        var currentWeightPath = Add(resultMatrix[i, k].PathWeight, resultMatrix[k, j].PathWeight);
                        resultMatrix[i, j].PathWeight = Math.Min(resultMatrix[i, j].PathWeight, currentWeightPath);
                    }
                }
            }
            return resultMatrix;
        }

        public void PrintMartrix(AdjacencyMatrixNode<T>[,] martrix)
        {
            //多维数组的遍历
            Console.WriteLine();
            var length = martrix.GetLength(0);
            for (int i = 0; i < length; i++)
            {
                Console.WriteLine();
                for (int j = 0; j < length; j++)
                {
                    var s = martrix[i, j].PathWeight == int.MaxValue ? "oo" : martrix[i, j].PathWeight.ToString();
                    var p = martrix[i, j].Predecessor == int.MaxValue ? "oo" : martrix[i, j].Predecessor.ToString();
                    //不支持表达式
                    Console.Write($"{s}, {p} \t");
                }
            }
        }


        private int Add(int a, int b)
        {
            if (a == int.MaxValue || b == int.MaxValue)
            {
                return int.MaxValue;
            }
            return a + b;
        }
    }
}
