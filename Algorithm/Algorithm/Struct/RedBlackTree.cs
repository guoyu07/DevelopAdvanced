﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Algorithm.Struct
{
	//插入和删除太复杂了
	public class RedBlackTree<T> : BinarySearchTree<T> where T : IComparable
	{
		public static RedBlackTreeNode<T> Empty { get; set; }
			= new RedBlackTreeNode<T>()
			{
				Color = NodeColor.Black
			};


		public RedBlackTree()
		{

		}


		#region Rotate  //看着图写步骤，并不是太复杂的逻辑


		public void LeftRotate(BinaryTreeNode<T> sourceNode)
		{
			var targetNode = sourceNode.Right;

			#region //使targetNode的Left节点变成source的right节点

			sourceNode.Right = targetNode.Left;
			targetNode.Left.Parent = sourceNode;

			#endregion


			#region //使targetNode的变成source的父亲节点

			targetNode.Parent = sourceNode.Parent;

			//漏掉的逻辑,设置parent引用
			if (sourceNode.Parent == Empty)
			{
				Root = targetNode;
			}
			else if (sourceNode == sourceNode.Parent.Left)
			{
				sourceNode.Parent.Left = targetNode;
			}
			else
			{
				sourceNode.Parent.Right = targetNode;

			}

			targetNode.Left = sourceNode;

			sourceNode.Parent = targetNode;


			#endregion

		}


		public void RightRotate(BinaryTreeNode<T> sourceNode)
		{
			var targetNode = sourceNode.Parent;

			#region 使source的right节点成为target的left节点

			targetNode.Left = sourceNode.Right;
			sourceNode.Right.Parent = targetNode;

			#endregion

			#region 使source的成为target的parent node

			sourceNode.Parent = targetNode.Parent;

			//设置parent的引用
			if (targetNode.Parent == Empty)
			{
				Root = sourceNode;
			}
			else if (targetNode.Parent.Right == targetNode)
			{
				targetNode.Parent.Right = sourceNode;
			}
			else
			{
				targetNode.Parent.Left = sourceNode;
			}

			sourceNode.Right = targetNode;

			targetNode.Parent = sourceNode;

			#endregion

		}


		#endregion
	}


}
