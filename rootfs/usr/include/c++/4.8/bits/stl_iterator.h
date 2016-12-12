// Iterators -*- C++ -*-

// Copyright (C) 2001-2013 Free Software Foundation, Inc.
//
// This file is part of the GNU ISO C++ Library.  This library is free
// software; you can redistribute it and/or modify it under the
// terms of the GNU General Public License as published by the
// Free Software Foundation; either version 3, or (at your option)
// any later version.

// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// Under Section 7 of GPL version 3, you are granted additional
// permissions described in the GCC Runtime Library Exception, version
// 3.1, as published by the Free Software Foundation.

// You should have received a copy of the GNU General Public License and
// a copy of the GCC Runtime Library Exception along with this program;
// see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see
// <http://www.gnu.org/licenses/>.

/*
 *
 * Copyright (c) 1994
 * Hewlett-Packard Company
 *
 * Permission to use, copy, modify, distribute and sell this software
 * and its documentation for any purpose is hereby granted without fee,
 * provided that the above copyright notice appear in all copies and
 * that both that copyright notice and this permission notice appear
 * in supporting documentation.  Hewlett-Packard Company makes no
 * representations about the suitability of this software for any
 * purpose.  It is provided "as is" without express or implied warranty.
 *
 *
 * Copyright (c) 1996-1998
 * Silicon Graphics Computer Systems, Inc.
 *
 * Permission to use, copy, modify, distribute and sell this software
 * and its documentation for any purpose is hereby granted without fee,
 * provided that the above copyright notice appear in all copies and
 * that both that copyright notice and this permission notice appear
 * in supporting documentation.  Silicon Graphics makes no
 * representations about the suitability of this software for any
 * purpose.  It is provided "as is" without express or implied warranty.
 */

/** @file bits/stl_iterator.h
 *  This is an internal header file, included by other library headers.
 *  Do not attempt to use it directly. @headername{iterator}
 *
 *  This file implements reverse_iterator, back_insert_iterator,
 *  front_insert_iterator, insert_iterator, __normal_iterator, and their
 *  supporting functions and overloaded operators.
 */

#ifndef _STL_ITERATOR_H
#define _STL_ITERATOR_H 1

#include <bits/cpp_type_traits.h>
#include <ext/type_traits.h>
#include <bits/move.h>

namespace std _GLIBCXX_VISIBILITY(default)
{
_GLIBCXX_BEGIN_NAMESPACE_VERSION

  /**
   * @addtogroup iterators
   * @{
   */

  // 24.4.1 Reverse iterators
  /**
   *  Bidirectional and random access iterators have corresponding reverse
   *  %iterator adaptors that iterate through the data structure in the
   *  opposite direction.  They have the same signatures as the corresponding
   *  iterators.  The fundamental relation between a reverse %iterator and its
   *  corresponding %iterator @c i is established by the identity:
   *  @code
   *      &*(reverse_iterator(i)) == &*(i - 1)
   *  @endcode
   *
   *  <em>This mapping is dictated by the fact that while there is always a
   *  pointer past the end of an array, there might not be a valid pointer
   *  before the beginning of an array.</em> [24.4.1]/1,2
   *
   *  Reverse iterators can be tricky and surprising at first.  Their
   *  semantics make sense, however, and the trickiness is a side effect of
   *  the requirement that the iterators must be safe.
  */
  template<typename _Iterator>
    class reverse_iterator
    : public iterator<typename iterator_traits<_Iterator>::iterator_category,
		      typename iterator_traits<_Iterator>::value_type,
		      typename iterator_traits<_Iterator>::difference_type,
		      typename iterator_traits<_Iterator>::pointer,
                      typename iterator_traits<_Iterator>::reference>
    {
    protected:
      _Iterator current;

      typedef iterator_traits<_Iterator>		__traits_type;

    public:
      typedef _Iterator					iterator_type;
      typedef typename __traits_type::difference_type	difference_type;
      typedef typename __traits_type::pointer		pointer;
      typedef typename __traits_type::reference		reference;

      /**
       *  The default constructor value-initializes member @p current.
       *  If it is a pointer, that means it is zero-initialized.
      */
      // _GLIBCXX_RESOLVE_LIB_DEFECTS
      // 235 No specification of default ctor for reverse_iterator
      reverse_iterator() : current() { }

      /**
       *  This %iterator will move in the opposite direction that @p x does.
      */
      explicit
      reverse_iterator(iterator_type __x) : current(__x) { }

      /**
       *  The copy constructor is normal.
      */
      reverse_iterator(const reverse_iterator& __x)
      : current(__x.current) { }

      /**
       *  A %reverse_iterator across other types can be copied if the
       *  underlying %iterator can be converted to the type of @c current.
      */
      template<typename _Iter>
        reverse_iterator(const reverse_iterator<_Iter>& __x)
	: current(__x.base()) { }

      /**
       *  @return  @c current, the %iterator used for underlying work.
      */
      iterator_type
      base() const
      { return current; }

      /**
       *  @return  A reference to the value at @c --current
       *
       *  This requires that @c --current is dereferenceable.
       *
       *  @warning This implementation requires that for an iterator of the
       *           underlying iterator type, @c x, a reference obtained by
       *           @c *x remains valid after @c x has been modified or
       *           destroyed. This is a bug: http://gcc.gnu.org/PR51823
      */
      reference
      operator*() const
      {
	_Iterator __tmp = current;
	return *--__tmp;
      }

      /**
       *  @return  A pointer to the value at @c --current
       *
       *  This requires that @c --current is dereferenceable.
      */
      pointer
      operator->() const
      { return &(operator*()); }

      /**
       *  @return  @c *this
       *
       *  Decrements the underlying iterator.
      */
      reverse_iterator&
      operator++()
      {
	--current;
	return *this;
      }

      /**
       *  @return  The original value of @c *this
       *
       *  Decrements the underlying iterator.
      */
      reverse_iterator
      operator++(int)
      {
	reverse_iterator __tmp = *this;
	--current;
	return __tmp;
      }

      /**
       *  @return  @c *this
       *
       *  Increments the underlying iterator.
      */
      reverse_iterator&
      operator--()
      {
	++current;
	return *this;
      }

      /**
       *  @return  A reverse_iterator with the previous value of @c *this
       *
       *  Increments the underlying iterator.
      */
      reverse_iterator
      operator--(int)
      {
	reverse_iterator __tmp = *this;
	++current;
	return __tmp;
      }

      /**
       *  @return  A reverse_iterator that refers to @c current - @a __n
       *
       *  The underlying iterator must be a Random Access Iterator.
      */
      reverse_iterator
      operator+(difference_type __n) const
      { return reverse_iterator(current - __n); }

      /**
       *  @return  *this
       *
       *  Moves the underlying iterator backwards @a __n steps.
       *  The underlying iterator must be a Random Access Iterator.
      */
      reverse_iterator&
      operator+=(difference_type __n)
      {
	current -= __n;
	return *this;
      }

      /**
       *  @return  A reverse_iterator that refers to @c current - @a __n
       *
       *  The underlying iterator must be a Random Access Iterator.
      */
      reverse_iterator
      operator-(difference_type __n) const
      { return reverse_iterator(current + __n); }

      /**
       *  @return  *this
       *
       *  Moves the underlying iterator forwards @a __n steps.
       *  The underlying iterator must be a Random Access Iterator.
      */
      reverse_iterator&
      operator-=(difference_type __n)
      {
	current += __n;
	return *this;
      }

      /**
       *  @return  The value at @c current - @a __n - 1
       *
       *  The underlying iterator must be a Random Access Iterator.
      */
      reference
      operator[](difference_type __n) const
      { return *(*this + __n); }
    };

  //@{
  /**
   *  @param  __x  A %reverse_iterator.
   *  @param  __y  A %reverse_iterator.
   *  @return  A simple bool.
   *
   *  Reverse iterators forward many operations to their underlying base()
   *  iterators.  Others are implemented in terms of one another.
   *
  */
  template<typename _Iterator>
    inline bool
    operator==(const reverse_iterator<_Iterator>& __x,
	       const reverse_iterator<_Iterator>& __y)
    { return __x.base() == __y.base(); }

  template<typename _Iterator>
    inline bool
    operator<(const reverse_iterator<_Iterator>& __x,
	      const reverse_iterator<_Iterator>& __y)
    { return __y.base() < __x.base(); }

  template<typename _Iterator>
    inline bool
    operator!=(const reverse_iterator<_Iterator>& __x,
	       const reverse_iterator<_Iterator>& __y)
    { return !(__x == __y); }

  template<typename _Iterator>
    inline bool
    operator>(const reverse_iterator<_Iterator>& __x,
	      const reverse_iterator<_Iterator>& __y)
    { return __y < __x; }

  template<typename _Iterator>
    inline bool
    operator<=(const reverse_iterator<_Iterator>& __x,
	       const reverse_iterator<_Iterator>& __y)
    { return !(__y < __x); }

  template<typename _Iterator>
    inline bool
    operator>=(const reverse_iterator<_Iterator>& __x,
	       const reverse_iterator<_Iterator>& __y)
    { return !(__x < __y); }

  template<typename _Iterator>
    inline typename reverse_iterator<_Iterator>::difference_type
    operator-(const reverse_iterator<_Iterator>& __x,
	      const reverse_iterator<_Iterator>& __y)
    { return __y.base() - __x.base(); }

  template<typename _Iterator>
    inline reverse_iterator<_Iterator>
    operator+(typename reverse_iterator<_Iterator>::difference_type __n,
	      const reverse_iterator<_Iterator>& __x)
    { return reverse_iterator<_Iterator>(__x.base() - __n); }

  // _GLIBCXX_RESOLVE_LIB_DEFECTS
  // DR 280. Comparison of reverse_iterator to const reverse_iterator.
  template<typename _IteratorL, typename _IteratorR>
    inline bool
    operator==(const reverse_iterator<_IteratorL>& __x,
	       const reverse_iterator<_IteratorR>& __y)
    { return __x.base() == __y.base(); }

  template<typename _IteratorL, typename _IteratorR>
    inline bool
    operator<(const reverse_iterator<_IteratorL>& __x,
	      const reverse_iterator<_IteratorR>& __y)
    { return __y.base() < __x.base(); }

  template<typename _IteratorL, typename _IteratorR>
    inline bool
    operator!=(const reverse_iterator<_IteratorL>& __x,
	       const reverse_iterator<_IteratorR>& __y)
    { return !(__x == __y); }

  template<typename _IteratorL, typename _IteratorR>
    inline bool
    operator>(const reverse_iterator<_IteratorL>& __x,
	      const reverse_iterator<_IteratorR>& __y)
    { return __y < __x; }

  template<typename _IteratorL, typename _IteratorR>
    inline bool
    operator<=(const reverse_iterator<_IteratorL>& __x,
	       const reverse_iterator<_IteratorR>& __y)
    { return !(__y < __x); }

  template<typename _IteratorL, typename _IteratorR>
    inline bool
    operator>=(const reverse_iterator<_IteratorL>& __x,
	       const reverse_iterator<_IteratorR>& __y)
    { return !(__x < __y); }

  template<typename _IteratorL, typename _IteratorR>
#if __cplusplus >= 201103L
    // DR 685.
    inline auto
    operator-(const reverse_iterator<_IteratorL>& __x,
	      const reverse_iterator<_IteratorR>& __y)
    -> decltype(__y.base() - __x.base())
#else
    inline typename reverse_iterator<_IteratorL>::difference_type
    operator-(const reverse_iterator<_IteratorL>& __x,
	      const reverse_iterator<_IteratorR>& __y)
#endif
    { return __y.base() - __x.base(); }
  //@}

  // 24.4.2.2.1 back_insert_iterator
  /**
   *  @brief  Turns assignment into insertion.
   *
   *  These are output iterators, constructed from a container-of-T.
   *  Assigning a T to the iterator appends it to the container using
   *  push_back.
   *
   *  Tip:  Using the back_inserter function to create these iterators can
   *  save typing.
  */
  template<typename _Container>
    class back_insert_iterator
    : public iterator<output_iterator_tag, void, void, void, void>
    {
    protected:
      _Container* container;

    public:
      /// A nested typedef for the type of whatever container you used.
      typedef _Container          container_type;

      /// The only way to create this %iterator is with a container.
      explicit
      back_insert_iterator(_Container& __x) : container(&__x) { }

      /**
       *  @param  __value  An instance of whatever type
       *                 container_type::const_reference is; presumably a
       *                 reference-to-const T for container<T>.
       *  @return  This %iterator, for chained operations.
       *
       *  This kind of %iterator doesn't really have a @a position in the
       *  container (you can think of the position as being permanently at
       *  the end, if you like).  Assigning a value to the %iterator will
       *  always append the value to the end of the container.
      */
#if __cplusplus < 201103L
      back_insert_iterator&
      operator=(typename _Container::const_reference __value)
      {
	container->push_back(__value);
	return *this;
      }
#else
      back_insert_iterator&
      operator=(const typename _Container::value_type& __value)
      {
	container->push_back(__value);
	return *this;
      }

      back_insert_iterator&
      operator=(typename _Container::value_type&& __value)
      {
	container->push_back(std::move(__value));
	return *this;
      }
#endif

      /// Simply returns *this.
      back_insert_iterator&
      operator*()
      { return *this; }

      /// Simply returns *this.  (This %iterator does not @a move.)
      back_insert_iterator&
      operator++()
      { return *this; }

      /// Simply returns *this.  (This %iterator does not @a move.)
      back_insert_iterator
      operator++(int)
      { return *this; }
    };

  /**
   *  @param  __x  A container of arbitrary type.
   *  @return  An instance of back_insert_iterator working on @p __x.
   *
   *  This wrapper function helps in creating back_insert_iterator instances.
   *  Typing the name of the %iterator requires knowing the precise full
   *  type of the container, which can be tedious and impedes generic
   *  programming.  Using this function lets you take advantage of automatic
   *  template parameter deduction, making the compiler match the correct
   *  types for you.
  */
  template<typename _Container>
    inline back_insert_iterator<_Container>
    back_inserter(_Container& __x)
    { return back_insert_iterator<_Container>(__x); }

  /**
   *  @brief  Turns assignment into insertion.
   *
   *  These are output iterators, constructed from a container-of-T.
   *  Assigning a T to the iterator prepends it to the container using
   *  push_front.
   *
   *  Tip:  Using the front_inserter function to create these iterators can
   *  save typing.
  */
  template<typename _Container>
    class front_insert_iterator
    : public iterator<output_iterator_tag, void, void, void, void>
    {
    protected:
      _Container* container;

    public:
      /// A nested typedef for the type of whatever container you used.
      typedef _Container          container_type;

      /// The only way to create this %iterator is with a container.
      explicit front_insert_iterator(_Container& __x) : container(&__x) { }

      /**
       *  @param  __value  An instance of whatever type
       *                 container_type::const_reference is; presumably a
       *                 reference-to-const T for container<T>.
       *  @return  This %iterator, for chained operations.
       *
       *  This kind of %iterator doesn't really have a @a position in the
       *  container (you can think of the position as being permanently at
       *  the front, if you like).  Assigning a value to the %iterator will
       *  always prepend the value to the front of the container.
      */
#if __cplusplus < 201103L
      front_insert_iterator&
      operator=(typename _Container::const_reference __value)
      {
	container->push_front(__value);
	return *this;
      }
#else
      front_insert_iterator&
      operator=(const typename _Container::value_type& __value)
      {
	container->push_front(__value);
	return *this;
      }

      front_insert_iterator&
      operator=(typename _Container::value_type&& __value)
      {
	container->push_front(std::move(__value));
	return *this;
      }
#endif

      /// Simply returns *this.
      front_insert_iterator&
      operator*()
      { return *this; }

      /// Simply returns *this.  (This %iterator does not @a move.)
      front_insert_iterator&
      operator++()
      { return *this; }

      /// Simply returns *this.  (This %iterator does not @a move.)
      front_insert_iterator
      operator++(int)
      { return *this; }
    };

  /**
   *  @param  __x  A container of arbitrary type.
   *  @return  An instance of front_insert_iterator working on @p x.
   *
   *  This wrapper function helps in creating front_insert_iterator instances.
   *  Typing the name of the %iterator requires knowing the precise full
   *  type of the container, which can be tedious and impedes generic
   *  programming.  Using this function lets you take advantage of automatic
   *  template parameter deduction, making the compiler match the correct
   *  types for you.
  */
  template<typename _Container>
    inline front_insert_iterator<_Container>
    front_inserter(_Container& __x)
    { return front_insert_iterator<_Container>(__x); }

  /**
   *  @brief  Turns assignment into insertion.
   *
   *  These are output iterators, constructed from a container-of-T.
   *  Assigning a T to the iterator inserts it in the container at the
   *  %iterator's position, rather than overwriting the value at that
   *  position.
   *
   *  (Sequences will actually insert a @e copy of the value before the
   *  %iterator's position.)
   *
   *  Tip:  Using the inserter function to create these iterators can
   *  save typing.
  */
  template<typename _Container>
    class insert_iterator
    : public iterator<output_iterator_tag, void, void, void, void>
    {
    protected:
      _Container* container;
      typename _Container::iterator iter;

    public:
      /// A nested typedef for the type of whatever container you used.
      typedef _Container          container_type;

      /**
       *  The only way to create this %iterator is with a container and an
       *  initial position (a normal %iterator into the container).
      */
      insert_iterator(_Container& __x, typename _Container::iterator __i)
      : container(&__x), iter(__i) {}

      /**
       *  @param  __value  An instance of whatever type
       *                 container_type::const_reference is; presumably a
       *                 reference-to-const T for container<T>.
       *  @return  This %iterator, for chained operations.
       *
       *  This kind of %iterator maintains its own position in the
       *  container.  Assigning a value to the %iterator will insert the
       *  value into the container at the place before the %iterator.
       *
       *  The position is maintained such that subsequent assignments will
       *  insert values immediately after one another.  For example,
       *  @code
       *     // vector v contains A and Z
       *
       *     insert_iterator i (v, ++v.begin());
       *     i = 1;
       *     i = 2;
       *     i = 3;
       *
       *     // vector v contains A, 1, 2, 3, and Z
       *  @endcode
      */
#if __cplusplus < 201103L
      insert_iterator&
      operator=(typename _Container::const_reference __value)
      {
	iter = container->insert(iter, __value);
	++iter;
	return *this;
      }
#else
      insert_iterator&
      operator=(const typename _Container::value_type& __value)
      {
	iter = container->insert(iter, __value);
	++iter;
	return *this;
      }

      insert_iterator&
      operator=(typename _Container::value_type&& __value)
      {
	iter = container->insert(iter, std::move(__value));
	++iter;
	return *this;
      }
#endif

      /// Simply returns *this.
      insert_iterator&
      operator*()
      { return *this; }

      /// Simply returns *this.  (This %iterator does not @a move.)
      insert_iterator&
      operator++()
      { return *this; }

      /// Simply returns *this.  (This %iterator does not @a move.)
      insert_iterator&
      operator++(int)
      { return *this; }
    };

  /**
   *  @param __x  A container of arbitrary type.
   *  @return  An instance of insert_iterator working on @p __x.
   *
   *  This wrapper function helps in creating insert_iterator instances.
   *  Typing the name of the %iterator requires knowing the precise full
   *  type of the container, which can be tedious and impedes generic
   *  programming.  Using this function lets you take advantage of automatic
   *  template parameter deduction, making the compiler match the correct
   *  types for you.
  */
  template<typename _Container, typename _Iterator>
    inline insert_iterator<_Container>
    inserter(_Container& __x, _Iterator __i)
    {
      return insert_iterator<_Container>(__x,
					 typename _Container::iterator(__i));
    }

  // @} group iterators

_GLIBCXX_END_NAMESPACE_VERSION
} // namespace

namespace __gnu_cxx _GLIBCXX_VISIBILITY(default)
{
_GLIBCXX_BEGIN_NAMESPACE_VERSION

  // This iterator adapter is @a normal in the sense that it does not
  // change the semantics of any of the operators of its iterator
  // parameter.  Its primary purpose is to convert an iterator that is
  // not a class, e.g. a pointer, into an iterator that is a class.
  // The _Container parameter exists solely so that different containers
  // using this template can instantiate different types, even if the
  // _Iterator parameter is the same.
  using std::iterator_traits;
  using std::iterator;
  template<typename _Iterator, typename _Container>
    class __normal_iterator
    {
    protected:
      _Iterator _M_current;

      typedef iterator_traits<_Iterator>		__traits_type;

    public:
      typedef _Iterator					iterator_type;
      typedef typename __traits_type::iterator_category iterator_category;
      typedef typename __traits_type::value_type  	value_type;
      typedef typename __traits_type::difference_type 	difference_type;
      typedef typename __traits_type::reference 	reference;
      typedef typename __traits_type::pointer   	pointer;

      _GLIBCXX_CONSTEXPR __normal_iterator() : _M_current(_Iterator()) { }

      explicit
      __normal_iterator(const _Iterator& __i) : _M_current(__i) { }

      // Allow iterator to const_iterator conversion
      template<typename _Iter>
        __normal_iterator(const __normal_iterator<_Iter,
			  typename __enable_if<
      	       (std::__are_same<_Iter, typename _Container::pointer>::__value),
		      _Container>::__type>& __i)
        : _M_current(__i.base()) { }

      // Forward iterator requirements
      reference
      operator*() const
      { return *_M_current; }

      pointer
      operator->() const
      { return _M_current; }

      __normal_iterator&
      operator++()
      {
	++_M_current;
	return *this;
      }

      __normal_iterator
      operator++(int)
      { return __normal_iterator(_M_current++); }

      // Bidirectional iterator requirements
      __normal_iterator&
      operator--()
      {
	--_M_current;
	return *this;
      }

      __normal_iterator
      operator--(int)
      { return __normal_iterator(_M_current--); }

      // Random access iterator requirements
      reference
      operator[](const difference_type& __n) const
      { return _M_current[__n]; }

      __normal_iterator&
      operator+=(const difference_type& __n)
      { _M_current += __n; return *this; }

      __normal_iterator
      operator+(const difference_type& __n) const
      { return __normal_iterator(_M_current + __n); }

      __normal_iterator&
      operator-=(const difference_type& __n)
      { _M_current -= __n; return *this; }

      __normal_iterator
      operator-(const difference_type& __n) const
      { return __normal_iterator(_M_current - __n); }

      const _Iterator&
      base() const
      { return _M_current; }
    };

  // Note: In what follows, the left- and right-hand-side iterators are
  // allowed to vary in types (conceptually in cv-qualification) so that
  // comparison between cv-qualified and non-cv-qualified iterators be
  // valid.  However, the greedy and unfriendly operators in std::rel_ops
  // will make overload resolution ambiguous (when in scope) if we don't
  // provide overloads whose operands are of the same type.  Can someone
  // remind me what generic programming is about? -- Gaby

  // Forward iterator requirements
  template<typename _IteratorL, typename _IteratorR, typename _Container>
    inline bool
    operator==(const __normal_iterator<_IteratorL, _Container>& __lhs,
	       const __normal_iterator<_IteratorR, _Container>& __rhs)
    { return __lhs.base() == __rhs.base(); }

  template<typename _Iterator, typename _Container>
    inline bool
    operator==(const __normal_iterator<_Iterator, _Container>& __lhs,
	       const __normal_iterator<_Iterator, _Container>& __rhs)
    { return __lhs.base() == __rhs.base(); }

  template<typename _IteratorL, typename _IteratorR, typename _Container>
    inline bool
    operator!=(const __normal_iterator<_IteratorL, _Container>& __lhs,
	       const __normal_iterator<_IteratorR, _Container>& __rhs)
    { return __lhs.base() != __rhs.base(); }

  template<typename _Iterator, typename _Container>
    inline bool
    operator!=(const __normal_iterator<_Iterator, _Container>& __lhs,
	       const __normal_iterator<_Iterator, _Container>& __rhs)
    { return __lhs.base() != __rhs.base(); }

  // Random access iterator requirements
  template<typename _IteratorL, typename _IteratorR, typename _Container>
    inline bool
    operator<(const __normal_iterator<_IteratorL, _Container>& __lhs,
	      const __normal_iterator<_IteratorR, _Container>& __rhs)
    { return __lhs.base() < __rhs.base(); }

  template<typename _Iterator, typename _Container>
    inline bool
    operator<(const __normal_iterator<_Iterator, _Container>& __lhs,
	      const __normal_iterator<_Iterator, _Container>& __rhs)
    { return __lhs.base() < __rhs.base(); }

  template<typename _IteratorL, typename _IteratorR, typename _Container>
    inline bool
    operator>(const __normal_iterator<_IteratorL, _Container>& __lhs,
	      const __normal_iterator<_IteratorR, _Container>& __rhs)
    { return __lhs.base() > __rhs.base(); }

  template<typename _Iterator, typename _Container>
    inline bool
    operator>(const __normal_iterator<_Iterator, _Container>& __lhs,
	      const __normal_iterator<_Iterator, _Container>& __rhs)
    { return __lhs.base() > __rhs.base(); }

  template<typename _IteratorL, typename _IteratorR, typename _Container>
    inline bool
    operator<=(const __normal_iterator<_IteratorL, _Container>& __lhs,
	       const __normal_iterator<_IteratorR, _Container>& __rhs)
    { return __lhs.base() <= __rhs.base(); }

  template<typename _Iterator, typename _Container>
    inline bool
    operator<=(const __normal_iterator<_Iterator, _Container>& __lhs,
	       const __normmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm        0∆ƒú@                  –^£ù@                                         §      ˇˇˇˇ            0∆ƒú@                  –^£ù@                                         Ù      ˇˇˇˇ            0∆ƒú@                  –^£ù@                                         ı      ˇˇˇˇ            0∆ƒú@                  –^£ù@                                         ˆ      ˇˇˇˇ            0∆ƒú@                  –^£ù@                                         ˜      ˇˇˇˇ            0∆ƒú@                        %u@  `$u@   ˇ¿û   „-¿|   †2¡û                                 XP¡û  –[£ù@  x ¡û         –[£ù@  êÙ¿û         –[£ù@  ¿¡û         –[£ù@  ¯¡û         –[£ù@  0¡û         –[£ù@  h¡û         –[£ù@  †¡û         –[£ù@  ÿ¡û         –[£ù@  ¡û         –[£ù@  H¡û         –[£ù@  Ä¡û         –[£ù@  ∏¡û         –[£ù@  ¡û         –[£ù@  (¡û         –[£ù@  `¡û         –[£ù@  ò¡û         –[£ù@  –¡û         –[£ù@  ¡û         –[£ù@  @¡û         –[£ù@  x¡û         –[£ù@  Xq2¡û    Ä     –[£ù@  Xq2¡û    Ä     –[£ù@  Xq2¡û    Ä     –[£ù@  Xq2¡û    Ä     –[£ù@  Xq2¡û    Ä     –[£ù@  Xq2¡û    Ä     –[£ù@  Xq2¡û    Ä     –[£ù@  Xq2¡û    Ä     –[£ù@  Xq2¡û    Ä     –[£ù@  Xq2¡û    Ä     –[£ù@  Xq2¡û    Ä     –[£ù@  ¡û    Ñ     –[£ù@  Xq2¡û    Ä     –[£ù@  Ä¡û    Ñ     –[£ù@  Xq2¡û    Ä     –[£ù@  ¡û    Ñ     –[£ù@  Xq2¡û    Ä     –[£ù@  `¡û    Ñ     –[£ù@  Xq2¡û    Ä     –[£ù@  –¡û    Ñ     –[£ù@  Xq2¡û    Ä     –[£ù@  @¡û    Ñ     –[£ù@  Xq2¡û    Ä     –[£ù@  ∞¡û    Ñ     –[£ù@  Xq2¡û    Ä     –[£ù@   ¡û         –[£ù@  Hu2¡û         –[£ù@  Xq2¡û         –[£ù@  ê¡û         –[£ù@   	¡û         –[£ù@  p	¡û         –[£ù@  ‡	¡û         –[£ù@  P
¡û         –[£ù@  ¿
¡û         –[£ù@  0¡û         –[£ù@  h¡û         –[£ù@  ÿ¡û         –[£ù@  Xq2¡û    Ä     –[£ù@  Xq2¡û    Ä     –[£ù@  ê¡û     
    –[£ù@  Xq2¡û    Ä     –[£ù@  Xq2¡û    Ä     –[£ù@   ë¡û     
    –[£ù@  Xq2¡û    Ä     –[£ù@  Xq2¡û    Ä     –[£ù@  êë¡û     
    –[£ù@  Xq2¡û    Ä     –[£ù@  Xq2¡û    Ä     –[£ù@  8í¡û         –[£ù@  Xq2¡û    Ä     –[£ù@  Xq2¡û    Ä     –[£ù@  ®í¡û         –[£ù@  Xq2¡û    Ä     –[£ù@  Xq2¡û    Ä     –[£ù@  ì¡û         –[£ù@  Xq2¡û    Ä     –[£ù@  Xq2¡û    Ä     –[£ù@  ¿ì¡û         –[£ù@  Xq2¡û    Ä     –[£ù@  Xq2¡û    Ä     –[£ù@  ¯ì¡û         –[£ù@  Xq2¡û    Ä     –[£ù@  Xq2¡û    Ä     –[£ù@  †î¡û         –[£ù@  Xq2¡û    Ä     –[£ù@  Xq2¡û    Ä     –[£ù@  Äï¡û         –[£ù@  Xq2¡û    Ä     –[£ù@  Xq2¡û    Ä     –[£ù@  `ñ¡û         –[£ù@  Xq2¡û    Ä     –[£ù@  Xq2¡û    Ä     –[£ù@  Xq2¡û    Ä     –[£ù@  Xq2¡û    Ä     –[£ù@  Xq2¡û    Ä     –[£ù@  Xq2¡û    Ä     –[£ù@  Xq2¡û    Ä     –[£ù@  Xq2¡û    Ä     –[£ù@  Xq2¡û    Ä     –[£ù@  Xq2¡û    Ä     –[£ù@  Xq2¡û    Ä     –[£ù@  Xq2¡û    Ä     –[£ù@  Xq2¡û    Ä     –[£ù@  Xq2¡û    Ä     –[£ù@  ÿõ¡û    Ä     –[£ù@  Xq2¡û    Ä     –[£ù@  Hú¡û    Ä     –[£ù@  Xq2¡û    Ä     –[£ù@  ∏ú¡û    Ä     –[£ù@  Xq2¡û    Ä     –[£ù@  (ù¡û    Ä     –[£ù@  Xq2¡û    Ä     –[£ù@  Xq2¡û    Ä     –[£ù@  Xq2¡û    Ä     –[£ù@  Xq2¡û    Ä     –[£ù@  Xq2¡û    Ä     –[£ù@  Xq2¡û    Ä     –[£ù@  Xq2¡û    Ä     –[£ù@  Xq2¡û    Ä     –[£ù@  Xq2¡û    Ä     –[£ù@  Xq2¡û    Ä     –[£ù@  Xq2¡û    Ä     –[£ù@  »—˛¿û         –[£ù@  Xq2¡û    Ä     –[£ù@  8“˛¿û         –[£ù@  Xq2¡û    Ä     –[£ù@  Xq2¡û    Ä     –[£ù@  ”˛¿û         –[£ù@  Xq2¡û    Ä     –[£ù@  à”˛¿û         –[£ù@  Xq2¡û    Ä     –[£ù@  h‘˛¿û    Ä     –[£ù@  Xq2¡û    Ä     –[£ù@  ÿ‘˛¿û    Ä     –[£ù@  Xq2¡û    Ä     –[£ù@  H’˛¿û    Ä     –[£ù@  Xq2¡û    Ä     –[£ù@  ∏’˛¿û    Ä     –[£ù@  Xq2¡û    Ä     –[£ù@  (÷˛¿û    Ä     –[£ù@  Xq2¡û    Ä     –[£ù@  ò÷˛¿û    Ä     –[£ù@  Xq2¡û    Ä     –[£ù@  ◊˛¿û    Ä     –[£ù@  Xq2¡û    Ä     –[£ù@  x◊˛¿û    Ä     –[£ù@  Xq2¡û    Ä     –[£ù@  Ë◊˛¿û    Ä     –[£ù@  Xq2¡û    Ä     –[£ù@   ÿ˛¿û         –[£ù@  Xq2¡û    Ä     –[£ù@  êÿ˛¿û         –[£ù@  Xq2¡û    Ä     –[£ù@   Ÿ˛¿û         –[£ù@  Xq2¡û    Ä     –[£ù@  Xq2¡û    Ä     –[£ù@  Xq2¡û    Ä     –[£ù@  Xq2¡û    Ä     –[£ù@  Xq2¡û    Ä     –[£ù@  Xq2¡û    Ä     –[£ù@  Xq2¡û    Ä     –[£ù@  Xq2¡û    Ä     –[£ù@  Xq2¡û    Ä     –[£ù@  Xq2¡û    Ä     –[£ù@  Xq2¡û    Ä     –[£ù@  ∏u2¡û    Ä     –[£ù@  @ﬁ˛¿û     
     h    %u@  @ê%u@   †¡û   ‰-¿|   ‡¡û                                ê`¡û                                                          pÖ©ù@                hS,¡û  »Ä¡û   a¡û  ∞Ä¡û                 ÄH¡û  H£¡û  H£¡û         pÖ©ù@                8T,¡û  H˚¡û          0˚¡û                `A¡û  H£¡û  H£¡û          pÖ©ù@                8T,¡û  †˚¡û          à˚¡û                ¿A¡û  H£¡û  H£¡û          pÖ©ù@                8T,¡û  ¯˚¡û          ‡˚¡û                 B¡û  H£¡û  H£¡û          pÖ©ù@                8T,¡û  ˙¡û          ÿ˙¡û                ÄB¡û  H£¡û  H£¡û          pÖ©ù@                8T,¡û  P¸¡û          8¸¡û                ‡B¡û  H£¡û  H£¡û          pÖ©ù@                8T,¡û  ®¸¡û          ê¸¡û                @C¡û  H£¡û  H£¡û          pÖ©ù@                8T,¡û   ˝¡û          Ë¸¡û                †C¡û  H£¡û  H£¡û          pÖ©ù@                8T,¡û  X˝¡û          @˝¡û                 D¡û  H£¡û  H£¡û          pÖ©ù@                8T,¡û  ∞˝¡û          ò˝¡û                `D¡û  H£¡û  H£¡û          pÖ©ù@                8T,¡û  ˛¡û          ˝¡û                ¿D¡û  H£¡û  H£¡û          pÖ©ù@                8T,¡û  `˛¡û          H˛¡û                 E¡û  H£¡û  H£¡û          pÖ©ù@                8T,¡û  ∏˛¡û          †˛¡û                ÄE¡û  H£¡û  H£¡û          pÖ©ù@                8T,¡û  ˇ¡û          ¯˛¡û                ‡E¡û  H£¡û  H£¡û          pÖ©ù@                8T,¡û  hˇ¡û          Pˇ¡û                @F¡û  H£¡û  H£¡û          pÖ©ù@                8T,¡û  ¿ˇ¡û          ®ˇ¡û                †F¡û  H£¡û  H£¡û          pÖ©ù@                8T,¡û  †p¡û          àp¡û                 G¡û  H£¡û  H£¡û          pÖ©ù@                8T,¡û  ¯p¡û          ‡p¡û                `G¡û  H£¡û  H£¡û          pÖ©ù@                8T,¡û  Pq¡û          8q¡û                ¿G¡û  H£¡û  H£¡û          pÖ©ù@                8T,¡û  ®q¡û          êq¡û                 H¡û  H£¡û  H£¡û          pÖ©ù@                8T,¡û   r¡û          Ëq¡û                ‡H¡û  H£¡û  H£¡û          pÖ©ù@                8T,¡û  Xr¡û          @r¡û                @I¡û  H£¡û  H£¡û          pÖ©ù@                8T,¡û  E,¡û           E,¡û                 J¡û  H£¡û  H£¡û          pÖ©ù@                8T,¡û  ∞r¡û          òr¡û                `J¡û  H£¡û  H£¡û          pÖ©ù@                8T,¡û  s¡û          r¡û                ¿J¡û  H£¡û  H£¡û          pÖ©ù@                8T,¡û  `s¡û          Hs¡û                 K¡û  H£¡û  H£¡û          pÖ©ù@                8T,¡û  ∏s¡û          †s¡û                ÄK¡û  H£¡û  H£¡û          pÖ©ù@                8T,¡û  t¡û          ¯s¡û                ‡K¡û  H£¡û  H£¡û          pÖ©ù@                8T,¡û  ht¡û          Pt¡û                @L¡û  H£¡û  H£¡û          pÖ©ù@                8T,¡û  ¿t¡û          ®t¡û                †L¡û  H£¡û  H£¡û          pÖ©ù@                8T,¡û  u¡û           u¡û                 M¡û  H£¡û  H£¡û          pÖ©ù@                8T,¡û  pu¡û          Xu¡û                `M¡û  H£¡û  H£¡û          pÖ©ù@                8T,¡û  »u¡û          ∞u¡û                ¿M¡û  H£¡û  H£¡û          pÖ©ù@                8T,¡û   v¡û          v¡û                 N¡û  H£¡û  H£¡û          pÖ©ù@                8T,¡û  xv¡û          `v¡û                ÄN¡û  H£¡û  H£¡û          pÖ©ù@                8T,¡û  –v¡û          ∏v¡û                ‡